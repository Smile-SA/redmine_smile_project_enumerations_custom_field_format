require_dependency "projects_helper"

################
# Smile connent : why re-select all tabs ?

module Smile
  module Helpers
    module ProjectOverride
      module ProjectEnumerations
        def self.prepended(base)
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
                tabs.insert(index,
                            {:name => 'project_enumerations', :action => :edit_project_enumerations,
                             :partial => 'projects/settings/project_enumerations',
                             :label => :label_project_enumeration_plural})

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
        end
      end
    end
  end
end
