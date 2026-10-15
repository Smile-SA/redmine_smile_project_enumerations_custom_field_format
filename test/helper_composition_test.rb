# Run without a Redmine database: ruby test/helper_composition_test.rb
require 'minitest/autorun'

def require_dependency(_name); end

module ProjectsHelper
  def project_settings_tabs
    [{ name: 'categories', action: :manage_categories,
       partial: 'projects/settings/issue_categories', label: :label_issue_category_plural }]
  end
end

class User
  def self.current = new
  def allowed_to?(*_args) = true
end

class CustomField
  def self.where(**_options) = [Object.new]
end

Project = Struct.new(:enabled) do
  def module_enabled?(_name) = enabled
end

View = Class.new do
  include ProjectsHelper
  def initialize = @project = Project.new(true)
end

module OtherProjectTabs
  def project_settings_tabs = super + [{ name: 'other_plugin', action: :edit_project }]
end
ProjectsHelper.prepend(OtherProjectTabs)

require_relative '../lib/helpers/smile_helpers_projects'
ProjectsHelper.prepend(Helpers::SmileHelpersProjects::ProjectsOverride::ProjectEnumerations)

class HelperCompositionTest < Minitest::Test
  def test_keeps_other_plugin_tabs_in_views_created_before_patch
    names = View.new.project_settings_tabs.map { |tab| tab[:name] }
    assert_includes names, 'other_plugin'
    assert_includes names, 'categories'
    assert_includes names, 'project_enumerations'
    assert_includes names, 'project_list_values'
  end

  def test_repeated_calls_do_not_duplicate_tabs
    view = View.new
    2.times do
      assert_equal 1, view.project_settings_tabs.count { |tab| tab[:name] == 'project_enumerations' }
    end
  end
end
