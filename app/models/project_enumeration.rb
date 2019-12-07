# Redmine - project management software
# Copyright (C) 2006-2017  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class ProjectEnumeration < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :project
  belongs_to :custom_field

  ENUMERATION_STATUSES = %w(open locked closed)
  ENUMERATION_SHARINGS = %w(none descendants hierarchy tree system)

  validates_presence_of :value
  validates_uniqueness_of :value, :scope => [:project_id]
  validates_length_of :value, :maximum => 60

  validates_presence_of :custom_field

  validates_inclusion_of :status, :in => ENUMERATION_STATUSES
  validates_inclusion_of :sharing, :in => ENUMERATION_SHARINGS

  scope :valued, lambda {|arg| where("LOWER(#{table_name}.value) = LOWER(?)", arg.to_s.strip)}
  scope :like, lambda {|arg|
    if arg.present?
      pattern = "%#{arg.to_s.strip}%"
      where([Redmine::Database.like("#{Version.table_name}.value", '?'), pattern])
    end
  }

  scope :open, lambda { where(:status => 'open') }
  scope :status, lambda {|status|
    if status.present?
      where(:status => status.to_s)
    end
  }

  scope :visible, lambda {|*args|
    joins(:project).
    where(Project.allowed_to_condition(args.first || User.current, :view_issues))
  }

  scope :order_by_custom_field_then_position, lambda { joins(:custom_field).order('custom_fields.name, position') }

  scope :for_enumerations, lambda { joins(:custom_field).where('custom_fields.field_format' => 'project_enumeration') }

  scope :for_list_values, lambda { joins(:custom_field).where('custom_fields.field_format' => 'project_list_value') }

  safe_attributes 'value',
    'status',
    'sharing',
    'custom_field_id',
    'position'

  # Returns true if +user+ or current user is allowed to view the enumerations
  def visible?(user=User.current)
    user.allowed_to?(:view_issues, self.project)
  end

  def closed?
    status == 'closed'
  end

  def open?
    status == 'open'
  end

  def name; value end

  def to_s; value end

  def to_s_with_project
    "#{project} - #{value}"
  end

  # Enumerations are sorted by value
  def <=>(enumeration)
    value == enumeration.name ? id <=> enumeration.id : value <=> enumeration.name
  end

  # Sort Enumerations by status (open, locked then closed enumerations)
  def self.sort_by_status(enumerations)
    enumerations.sort do |a, b|
      if a.status == b.status
        a <=> b
      else
        b.status <=> a.status
      end
    end
  end

  # TODO add specific enumerations css
  # TODO css_classes needed for enumerations ?
  def css_classes
    [
      "version-#{status}"
    ].join(' ')
  end

  def self.fields_for_order_statement(table=nil)
    table ||= table_name
    [
      "#{table}.position, #{table}.value", "#{table}.id"
    ]
  end

  scope :sorted, lambda { order(fields_for_order_statement) }

  # Returns the sharings that +user+ can set the enumeration to
  def allowed_sharings(user = User.current)
    ENUMERATION_SHARINGS.select do |s|
      if sharing == s
        true
      else
        case s
        when 'system'
          # Only admin users can set a systemwide sharing
          user.admin?
        when 'hierarchy', 'tree'
          # Only users allowed to edit the root project can
          # set sharing to hierarchy or tree
          project.nil? || user.allowed_to?(:edit_project, project.root)
        else
          true
        end
      end
    end
  end

  # Returns true if the enumeration is shared, otherwise false
  def shared?
    sharing != 'none'
  end

  def self.update_each(project, attributes, project_shared_enumerations)
    transaction do
      attributes.each do |project_enumeration_id, project_enumeration_attributes|
        project_enumeration = project_shared_enumerations.find{|pe| pe.id.to_s == project_enumeration_id}
        if project_enumeration
          if block_given?
            yield project_enumeration, project_enumeration_attributes
          else
            project_enumeration.safe_attributes = project_enumeration_attributes
          end
          unless project_enumeration.save
            raise ActiveRecord::Rollback
          end
        end
      end
    end
  end
end
