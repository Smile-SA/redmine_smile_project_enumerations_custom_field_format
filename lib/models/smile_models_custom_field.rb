# Smile - add methods to the CustomField model
#

module Smile
  module Models
    module CustomFieldOverride
      module ProjectEnumerations
        # extend ActiveSupport::Concern

        def self.prepended(base)
          base.class_eval do
            scope :joins_projects, lambda {
              joins("LEFT JOIN #{table_name_prefix}custom_fields_projects#{table_name_suffix} AS cfp ON cfp.custom_field_id = #{CustomField.table_name}.id")
            }

            scope :enabled_on_project, lambda { |project|
              joins_projects.
              where('cfp.project_id' => project.id).
              or(
                joins_projects.
                where.not(:type => 'IssueCustomField')
              ).
              or(
                joins_projects.
                where(:is_for_all => true)
              ).
              distinct
            }

            scope :not_enabled_on_project, lambda { |project|
              enabled_project_ids = Project.joins_custom_fields.where(:id => project.id).pluck('cfp.custom_field_id')
              where.not('id' => enabled_project_ids).
              where(:type => 'IssueCustomField').
              where.not(:is_for_all => true)
            }
          end
        end
      end # module ProjectEnumerations
    end # module CustomFieldOverride
  end # module Models
end # module Smile
