# Smile - add methods to the CustomField model
#

module Smile
  module Models
    module CustomFieldOverride
      module ProjectEnumerations
        # extend ActiveSupport::Concern

        def self.prepended(base)
          base.class_eval do
            scope :for_project, lambda { |project|
              joins("LEFT JOIN #{table_name_prefix}custom_fields_projects#{table_name_suffix} AS cfp ON cfp.custom_field_id = #{CustomField.table_name}.id").
              where('cfp.project_id' => project.id)
            }
          end
        end
      end # module ProjectEnumerations
    end # module CustomFieldOverride
  end # module Models
end # module Smile
