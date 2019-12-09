require_dependency "projects_controller"

module Smile
  module Controllers
    module ProjectsOverride
      module ProjectEnumerations
        def self.prepended(base)
          project_enumerations_instance_methods = [
            :settings, # 1/ EXTENDED, RM V4.0.0 OK
          ]

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          trace_first_prefix = "#{base.name}    instance_methods  "
          trace_prefix       = "#{' ' * (base.name.length + 15)}  --->  "
          last_postfix       = '< (SM::CO::ProjectsOverride::ProjectEnumerations)'

          SmileTools::trace_by_line(
            smile_instance_methods,
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_smile_project_enumerations_custom_field_format
          )
        end

        # Extended to manage Project Enumerations
        def settings
          super

          # 1/ Enumerations
          @enumeration_custom_fields_enabled_on_project = CustomField.enabled_on_project(@project).where(:field_format => 'project_enumeration')

          @enumeration_custom_fields_not_enabled_on_project = CustomField.not_enabled_on_project(@project).where(:field_format => 'project_enumeration')

          @project_enumerations = @project.shared_enumerations

          @enumeration_custom_fields_enabled_on_project_options = @enumeration_custom_fields_enabled_on_project.collect do |c|
              type_name = c.type_name
              name = c.name
              if type_name != :label_issue_plural
                name = "#{l(type_name)} / #{name}"
              end
              [name, c.id]
            end

          @enumeration_custom_field_id = params[:enumeration_custom_field_id]
          unless @enumeration_custom_field_id.blank?
            @project_enumerations = @project_enumerations.where("custom_field_id = ?", @enumeration_custom_field_id.to_i)
          end

          @enumeration_value = params[:enumeration_value]
          unless @enumeration_value.blank?
            @project_enumerations = @project_enumerations.where("value LIKE ?", "%#{@enumeration_value}%")
          end

          @enumeration_status = params[:enumeration_status]
          unless @enumeration_status.blank?
            @project_enumerations = @project_enumerations.where("status = ?", @enumeration_status)
          end

          @enumeration_sharing = params[:enumeration_sharing]
          unless @enumeration_sharing.blank?
            @project_enumerations = @project_enumerations.where("sharing = ?", @enumeration_sharing)
          end


          # 2/ List values
          @list_value_custom_fields_enabled_on_project = CustomField.enabled_on_project(@project).where(:field_format => 'project_list_value')

          @list_value_custom_fields_not_enabled_on_project = CustomField.not_enabled_on_project(@project).where(:field_format => 'project_list_value')

          @project_list_values = @project.shared_list_values

          @list_value_custom_fields_enabled_on_project_options = @list_value_custom_fields_enabled_on_project.collect do |c|
              type_name = c.type_name
              name = c.name
              if type_name != :label_issue_plural
                name = "#{l(type_name)} / #{name}"
              end
              [name, c.id]
            end

          @list_value_custom_field_id = params[:list_value_custom_field_id]
          unless @list_value_custom_field_id.blank?
            @project_list_values = @project_list_values.where("custom_field_id = ?", @list_value_custom_field_id.to_i)
          end

          @list_value_value = params[:list_value_value]
          unless @list_value_value.blank?
            @project_list_values = @project_list_values.where("value LIKE ?", "%#{@list_value_value}%")
          end

          @list_value_status = params[:list_value_status]
          unless @list_value_status.blank?
            @project_list_values = @project_list_values.where("status = ?", @list_value_status)
          end

          @list_value_sharing = params[:list_value_sharing]
          unless @list_value_sharing.blank?
            @project_list_values = @project_list_values.where("sharing = ?", @list_value_sharing)
          end
        end
      end
    end
  end
end
