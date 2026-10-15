require_dependency "projects_helper"

module Helpers
  module SmileHelpersProjects
    module ProjectsOverride
      module ProjectEnumerations
        def project_settings_tabs
          tabs = super

          # 1/ Issue settings
          modules_tab = {:name => 'modules', :action => :select_project_modules,
                     :partial => 'projects/settings/modules',
                     :label => :label_module_plural}

          # Previous Redmine version (< 4)
          index = tabs.index(modules_tab)
          if index
            # Modules selection merged into info tab
            tabs.delete_at(index)

            # Insert new issues tab (moved from info tab)
            tabs.insert(index,
                {:name => 'issues', :action => :edit_project, :module => :issue_tracking, :partial => 'projects/settings/issues', :label => :label_issue_tracking}
              )
          end

          # Smile comment : re-select new added tabs
          tabs.select! {|tab|
            ################
            # Smile specific : manage controller in allowed_to?
            allowed_params = tab[:action]
            allowed_params = {:action => allowed_params, :controller => tab[:controller]} if tab[:controller]
            User.current.allowed_to?(allowed_params, @project)
          }
          tabs.select! {|tab| tab[:module].nil? || @project.module_enabled?(tab[:module])}

          # 2/ Project enumerations
          return tabs unless User.current.allowed_to?(:manage_project_enumerations, @project)

          options_tab = {:name => 'categories', :action => :manage_categories,
                     :partial => 'projects/settings/issue_categories',
                     :label => :label_issue_category_plural}

          index = tabs.index(options_tab)
          unless index # Needed for Redmine v3.4.x
            options_tab[:url] = {:tab => 'categories',
                             :version_status => params[:version_status],
                             :version_name => params[:version_name]}
            index = tabs.index(options_tab)
          end

          return tabs unless index

          any_enumeration_custom_field = (
            CustomField.where(:field_format => 'project_enumeration').count > 0
          )

          any_list_value_custom_field = (
            CustomField.where(:field_format => 'project_list_value').count > 0
          )

          if any_list_value_custom_field
            tabs.insert(index,
                        {:name => 'project_list_values', :action => :manage_project_enumerations,
                         :partial => 'projects/settings/project_list_values',
                         :label => :label_project_list_value_plural})
          end

          if any_enumeration_custom_field
            tabs.insert(index,
                        {:name => 'project_enumerations', :action => :manage_project_enumerations,
                         :partial => 'projects/settings/project_enumerations',
                         :label => :label_project_enumeration_plural})
          end

          # Smile comment : re-select new added tabs
          tabs.select! {|tab|
            ################
            # Smile specific : manage controller in allowed_to?
            allowed_params = tab[:action]
            allowed_params = {:action => allowed_params, :controller => tab[:controller]} if tab[:controller]
            User.current.allowed_to?(allowed_params, @project)
          }
          tabs.select! {|tab| tab[:module].nil? || @project.module_enabled?(tab[:module])}

          tabs
        end
      end
    end
  end
end
