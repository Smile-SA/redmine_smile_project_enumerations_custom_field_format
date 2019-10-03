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

          @project_enumerations = ::ProjectEnumeration.where(:project_id => @project.id).order_by_custom_field_then_value

          @enumeration_custom_fields_options = CustomField.where(:field_format => 'project_enumeration').collect do |c|
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
        end
      end
    end
  end
end
