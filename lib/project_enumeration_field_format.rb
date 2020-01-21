# Smile - redmine_smile_project_enumerations_custom_field_format enhancement
#
# Compatible with Redmine 4.0
#
# module Redmine::FieldFormat::ProjectEnumerationFormat
#
# * InstanceMethods
#   * possible_values_options
#   * possible_values_enumerations
#   * protected
#     * query_filter_values
#     * possible_values_enumerations
#     * filtered_enumerations_options


module Redmine
  module FieldFormat
    class ProjectEnumerationFormat < RecordList
      add 'project_enumeration'
      self.form_partial = 'custom_fields/formats/project_enumeration'
      field_attributes :version_status

      # + User
      self.customized_class_names = %w(Issue TimeEntry Version Document Project User)

      def possible_values_options(custom_field, object=nil)
        possible_values_enumerations(custom_field, object).collect{|v| [v.to_s, v.id.to_s] }
      end

      def before_custom_field_save(custom_field)
        super
        if custom_field.version_status.is_a?(Array)
          custom_field.version_status.map!(&:to_s).reject!(&:blank?)
        end
      end

      protected

      def query_filter_values(custom_field, query)
        project_enumerations = possible_values_enumerations(custom_field, query.project, true)
        ProjectEnumeration.sort_by_status(project_enumerations).collect{|s| ["#{s.project.name} - #{s.name}", s.id.to_s, l("version_status_#{s.status}")] }
      end

      def possible_values_enumerations(custom_field, object=nil, all_statuses=false)
        if object.is_a?(Array)
          projects = object.map {|o| o.respond_to?(:project) ? o.project : nil}.compact.uniq
          projects.map {|project| possible_values_enumerations(custom_field, project)}.reduce(:&) || []
        elsif (
          object.respond_to?(:project) &&
          object.project &&
          # Fix NATIVE bug
          !object.is_a?(Project) # Don't know why project responds to project !!!
        )
          scope = object.project.shared_enumerations.joins(:custom_field).where('custom_fields.id = ?', custom_field.id)
          filtered_enumerations_options(custom_field, scope, all_statuses)
        elsif (
          object &&
          (
            !object.respond_to?(:project) ||
            # Fix NATIVE bug
            object.is_a?(Project) # Don't know why project responds to project !!!
          ) &&
          custom_field.format.class.customized_class_names.include?(object.class.name)
        )
          scope = ::ProjectEnumeration.
            visible.
            joins(:custom_field).
            where('custom_fields.id = ?', custom_field.id)
          filtered_enumerations_options(custom_field, scope, all_statuses)
        elsif object.nil?
          scope = ::ProjectEnumeration.visible.where(:sharing => 'system')
          filtered_enumerations_options(custom_field, scope, all_statuses)
        else
          []
        end
      end

      def filtered_enumerations_options(custom_field, scope, all_statuses=false)
        if !all_statuses && custom_field.version_status.is_a?(Array)
          statuses = custom_field.version_status.map(&:to_s).reject(&:blank?)
          if statuses.any?
            scope = scope.where(:status => statuses.map(&:to_s))
          end
        end
        scope
      end
    end
  end # FieldFormatOverride
end # module RedmineOverride
