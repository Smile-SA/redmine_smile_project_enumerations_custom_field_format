# Smile - add methods to the Project model
#
# 1/ module ProjectEnumerations
# - #TODO RM issue id for Change

#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module ProjectOverride
      #*****************
      # 1/ ProjectEnumerations
      module ProjectEnumerations
        def self.prepended(base)
          project_enumeration_methods = [
            :shared_enumerations, # 1/ new method
            :shared_list_values,  # 2/ new method
          ]

          trace_prefix = "#{' ' * (base.name.length + 25)}  --->  "
          last_postfix       = '< (SM::MO::ProjectOverride::ProjectEnumerations)'

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = project_enumeration_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS          instance_methods  "
          else
            trace_first_prefix = "#{base.name}               instance_methods  "
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
        end # def self.prepended(base)


        # 1/ new method, RM 4.0 OK
        # Returns a scope of the Enumerations used by the project
        def shared_enumerations
          if new_record?
            ::ProjectEnumeration.
              joins(:project).
              preload(:project).
              where("#{Project.table_name}.status <> ? AND #{::ProjectEnumeration.table_name}.sharing = 'system'", ::Project::STATUS_ARCHIVED)
          else
            @shared_enumerations ||= begin
              r = root? ? self : root
              ::ProjectEnumeration.
                joins(:project).
                preload(:project, :custom_field).
                for_enumerations.
                where("#{Project.table_name}.id = #{id}" +
                        " OR (#{Project.table_name}.status <> #{::Project::STATUS_ARCHIVED} AND (" +
                          " #{::ProjectEnumeration.table_name}.sharing = 'system'" +
                          " OR (#{Project.table_name}.lft >= #{r.lft} AND #{Project.table_name}.rgt <= #{r.rgt} AND #{::ProjectEnumeration.table_name}.sharing = 'tree')" +
                          " OR (#{Project.table_name}.lft < #{lft} AND #{Project.table_name}.rgt > #{rgt} AND #{::ProjectEnumeration.table_name}.sharing IN ('hierarchy', 'descendants'))" +
                          " OR (#{Project.table_name}.lft > #{lft} AND #{Project.table_name}.rgt < #{rgt} AND #{::ProjectEnumeration.table_name}.sharing = 'hierarchy')" +
                        "))")
            end
          end
        end

        # 2/ new method, RM 4.0.3 OK
        # Returns a scope of the List Values used by the project
        def shared_list_values
          if new_record?
            ::ProjectEnumeration.
              joins(:project).
              preload(:project).
              where("#{Project.table_name}.status <> ? AND #{::ProjectEnumeration.table_name}.sharing = 'system'", ::Project::STATUS_ARCHIVED)
          else
            @shared_list_values ||= begin
              r = root? ? self : root
              ::ProjectEnumeration.
                joins(:project).
                preload(:project, :custom_field).
                for_list_values.
                where("#{Project.table_name}.id = #{id}" +
                        " OR (#{Project.table_name}.status <> #{::Project::STATUS_ARCHIVED} AND (" +
                          " #{::ProjectEnumeration.table_name}.sharing = 'system'" +
                          " OR (#{Project.table_name}.lft >= #{r.lft} AND #{Project.table_name}.rgt <= #{r.rgt} AND #{::ProjectEnumeration.table_name}.sharing = 'tree')" +
                          " OR (#{Project.table_name}.lft < #{lft} AND #{Project.table_name}.rgt > #{rgt} AND #{::ProjectEnumeration.table_name}.sharing IN ('hierarchy', 'descendants'))" +
                          " OR (#{Project.table_name}.lft > #{lft} AND #{Project.table_name}.rgt < #{rgt} AND #{::ProjectEnumeration.table_name}.sharing = 'hierarchy')" +
                        "))")
            end
          end
        end
      end # module ProjectEnumerations
    end # module ProjectOverride
  end # module Models
end # module Smile
