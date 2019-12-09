require_dependency "projects_helper"

################
# Smile connent : why re-select all tabs ?

module Smile
  module Helpers
    module ProjectsOverride
      module ProjectEnumerations
        def self.prepended(base)
          project_enumerations_instance_methods = [
            :project_settings_tabs, # 1/ EXTENDED RM 4.0.0 OK
          ]


          # Smile specific : EXTENDED
          # Smile comment : module_eval mandatory with helpers, that are included in classes without the module prepended sub-modules
          # Smile comment : but no more access to rewritten methods => use of alias method to access to ancestor version
          base.module_eval do
            # Extended
            def project_settings_tabs_with_project_enumerations
              tabs = project_settings_tabs_without_project_enumerations
              return tabs unless User.current.allowed_to?(:manage_project_enumerations, @project)

              options = {:name => 'categories', :action => :manage_categories,
                         :partial => 'projects/settings/issue_categories',
                         :label => :label_issue_category_plural}

              index = tabs.index(options)
              unless index # Needed for Redmine v3.4.x
                options[:url] = {:tab => 'categories',
                                 :version_status => params[:version_status],
                                 :version_name => params[:version_name]}
                index = tabs.index(options)
              end

              if index
                any_enumeration_custom_field = (
                  CustomField.where(:field_format => 'project_enumeration').count > 0
                )

                any_list_value_custom_field = (
                  CustomField.where(:field_format => 'project_list_value').count > 0
                )

                if any_list_value_custom_field
                  tabs.insert(index,
                              {:name => 'project_list_values', :action => :edit_project_list_values,
                               :partial => 'projects/settings/project_list_values',
                               :label => :label_project_list_value_plural})
                end

                if any_enumeration_custom_field
                  tabs.insert(index,
                              {:name => 'project_enumerations', :action => :edit_project_enumerations,
                               :partial => 'projects/settings/project_enumerations',
                               :label => :label_project_enumeration_plural})
                end

                # Smile connent : why re-select all tabs ?
                tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
              end

              tabs
            end
          end

          base.instance_eval do
            alias_method :project_settings_tabs_without_project_enumerations, :project_settings_tabs
            alias_method :project_settings_tabs, :project_settings_tabs_with_project_enumerations
          end


          trace_prefix       = "#{' ' * (base.name.length + 19)}  --->  "
          last_postfix       = '< (SM::HO::ProjectsOverride::ProjectEnumerations)'

          smile_instance_methods = base.instance_methods.select{|m|
              project_enumerations_instance_methods.include?(m) &&
                base.instance_method(m).source_location.first =~ SmileTools.regex_path_in_plugin(
                    'lib/helpers/smile_helpers_projects',
                    :redmine_smile_project_enumerations_custom_field_format
                  )
            }

          missing_instance_methods = project_enumerations_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS   instance_methods  "
          else
            trace_first_prefix = "#{base.name}        instance_methods  "
          end

          SmileTools::trace_by_line(
            (
              missing_instance_methods.any? ?
              missing_instance_methods :
              smile_instance_methods
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_smile_project_enumerations_custom_field_format
          )

          if missing_instance_methods.any?
            raise trace_first_prefix + missing_instance_methods.join(', ') + '  ' + last_postfix
          end
        end
      end
    end
  end
end
