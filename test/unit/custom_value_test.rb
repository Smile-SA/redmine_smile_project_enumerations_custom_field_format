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

require File.expand_path('../../test_helper', __FILE__)

class CustomValueTest < ActiveSupport::TestCase
  fixtures :projects, :issues

  plugin_fixtures :custom_fields, :custom_values, :project_enumerations, :custom_fields_projects, :custom_fields_trackers

  def test_new_without_value_should_set_default_value
    cf1 = IssueCustomField.find_by_id(1)

    assert_not_nil cf1
    assert_equal 'Project CF Enum 1', cf1.name
    assert_equal 'project_enumeration', cf1.field_format
  end
end
