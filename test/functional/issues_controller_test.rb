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

class IssuesControllerTest < Redmine::ControllerTest
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :issue_relations,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :enumerations,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

  include Redmine::I18n

  def setup
    User.current = nil

    @cf1_value1 = 'Cat. 1'
    @cf1_value2 = 'Cat. 2'
    @cf1_value3 = 'Cat. 3'
    @cf2_value4 = 'Enum. 1'
    @cf2_value5 = 'Enum. 2'
    @cf2_value6 = 'Enum. 3'
    @cf2_value7 = 'Enum. 4'
  end

  def test_index
=begin
    with_settings :default_language => "en" do
      get :index
      assert_response :success

      # links to visible issues
      assert_select 'a[href="/issues/1"]', :text => /Cannot print recipes/
      assert_select 'a[href="/issues/5"]', :text => /Subproject issue/
      # private projects hidden
      assert_select 'a[href="/issues/6"]', 0
      assert_select 'a[href="/issues/4"]', 0
      # project column
      assert_select 'th', :text => /Project/
    end
=end
  end

  def test_index_with_project_custom_field_filter
=begin
    field = ProjectCustomField.create!(:name => 'Client', :is_filter => true, :field_format => 'string')
    CustomValue.create!(:custom_field => field, :customized => Project.find(3), :value => 'Foo')
    CustomValue.create!(:custom_field => field, :customized => Project.find(5), :value => 'Foo')
    filter_name = "project.cf_#{field.id}"
    @request.session[:user_id] = 1

    get :index, :params => {
        :set_filter => 1,
        :f => [filter_name],
        :op => {
          filter_name => '='
        },
        :v => {
          filter_name => ['Foo']
        },
        :c => ['project']
      }
    assert_response :success

    assert_equal [3, 5], issues_in_list.map(&:project_id).uniq.sort
=end
  end

  def test_index_with_query_grouped_and_sorted_by_category
=begin
    get :index, :params => {
        :project_id => 1,
        :set_filter => 1,
        :group_by => "category",
        :sort => "category"
      }
    assert_response :success
    assert_select 'tr.group span.count'
=end
  end

  def test_index_with_query_grouped_and_sorted_by_fixed_version
=begin
    get :index, :params => {
        :project_id => 1,
        :set_filter => 1,
        :group_by => "fixed_version",
        :sort => "fixed_version"
      }
    assert_response :success
    assert_select 'tr.group span.count'
=end
  end

  def test_index_with_query_grouped_by_list_custom_field
=begin
    get :index, :params => {
        :project_id => 1,
        :query_id => 9
      }
    assert_response :success
    assert_select 'tr.group span.count'
=end
  end


  def test_show_should_display_update_form
=begin
    @request.session[:user_id] = 2
    get :show, :params => {
        :id => 1
      }
    assert_response :success

    assert_select 'form#issue-form' do
      assert_select 'input[name=?]', 'issue[is_private]'
      assert_select 'select[name=?]', 'issue[project_id]'
      assert_select 'select[name=?]', 'issue[tracker_id]'
      assert_select 'input[name=?]', 'issue[subject]'
      assert_select 'textarea[name=?]', 'issue[description]'
      assert_select 'select[name=?]', 'issue[status_id]'
      assert_select 'select[name=?]', 'issue[priority_id]'
      assert_select 'select[name=?]', 'issue[assigned_to_id]'
      assert_select 'select[name=?]', 'issue[category_id]'
      assert_select 'select[name=?]', 'issue[fixed_version_id]'
      assert_select 'input[name=?]', 'issue[parent_issue_id]'
      assert_select 'input[name=?]', 'issue[start_date]'
      assert_select 'input[name=?]', 'issue[due_date]'
      assert_select 'select[name=?]', 'issue[done_ratio]'
      assert_select 'input[name=?]', 'issue[custom_field_values][2]'
      assert_select 'input[name=?]', 'issue[watcher_user_ids][]', 0
      assert_select 'textarea[name=?]', 'issue[notes]'
    end
=end
  end

  def test_update_form_should_not_display_inactive_enumerations
=begin
    assert !IssuePriority.find(15).active?

    @request.session[:user_id] = 2
    get :show, :params => {
        :id => 1
      }
    assert_response :success

    assert_select 'form#issue-form' do
      assert_select 'select[name=?]', 'issue[priority_id]' do
        assert_select 'option[value="4"]'
        assert_select 'option[value="15"]', 0
      end
    end
=end
  end

  def test_show_should_display_category_field_if_categories_are_defined
=begin
    Issue.update_all :category_id => nil

    get :show, :params => {
        :id => 1
      }
    assert_response :success
    assert_select '.attributes .category'
=end
  end

  def test_show_should_not_display_category_field_if_no_categories_are_defined
=begin
    Project.find(1).issue_categories.delete_all

    get :show, :params => {
        :id => 1
      }
    assert_response :success
    assert_select 'table.attributes .category', 0
=end
  end

  def test_show_with_project_enumeration_custom_field
    get :show, :params => {
        :id => 2
      }
    assert_response :success

    assert_select ".cf_1 .value", :text => @cf1_value1
    assert_select ".cf_2 .value", :text => "#{@cf2_value4}, #{@cf2_value5}, #{@cf2_value6}"


    issue2 = Issue.find(2)
    issue2.custom_field_values = {2 => [4]}
    issue2.save!

    get :show, :params => {
        :id => 2
      }
    assert_response :success

    assert_select ".cf_1 .value", :text => @cf1_value1
    assert_select ".cf_2 .value", :text => @cf2_value4
  end

  def test_show_with_project_enumeration_custom_field_multiple_value_empty
    get :show, :params => {
        :id => 1
      }
    assert_response :success

    assert_select ".cf_1 .value", :text => "#{@cf1_value1}, #{@cf1_value2}, #{@cf1_value3}"
    assert_select ".cf_2 .value", :text => ''


    issue1 = Issue.find(1)
    issue1.custom_field_values = {1 => [1, 3]}
    issue1.save!


    get :show, :params => {
        :id => 1
      }
    assert_response :success

    assert_select ".cf_1 .value", :text => "#{@cf1_value1}, #{@cf1_value3}"
  end

  def test_show_with_project_enumeration_custom_multiple_removed
    cf1 = CustomField.find(1)
    cf1.update_attribute :multiple, false

    get :show, :params => {
        :id => 1
      }
    assert_response :success

    assert_select ".cf_1 .value", :text => @cf1_value3


    issue1 = Issue.find(1)
    issue1.custom_field_values = {1 => 2}
    issue1.save!

    get :show, :params => {
        :id => 1
      }
    assert_response :success

    assert_select ".cf_1 .value", :text => @cf1_value2
  end

  def test_get_new
=begin
    @request.session[:user_id] = 2
    get :new, :params => {
        :project_id => 1,
        :tracker_id => 1
      }
    assert_response :success

    assert_select 'form#issue-form[action=?]', '/projects/ecookbook/issues'
    assert_select 'form#issue-form' do
      assert_select 'input[name=?]', 'issue[is_private]'
      assert_select 'select[name=?]', 'issue[project_id]'
      assert_select 'select[name=?]', 'issue[tracker_id]'
      assert_select 'input[name=?]', 'issue[subject]'
      assert_select 'textarea[name=?]', 'issue[description]'
      assert_select 'select[name=?]', 'issue[status_id]'
      assert_select 'select[name=?]', 'issue[priority_id]'
      assert_select 'select[name=?]', 'issue[assigned_to_id]'
      assert_select 'select[name=?]', 'issue[category_id]'
      assert_select 'select[name=?]', 'issue[fixed_version_id]'
      assert_select 'input[name=?]', 'issue[parent_issue_id]'
      assert_select 'input[name=?]', 'issue[start_date]'
      assert_select 'input[name=?]', 'issue[due_date]'
      assert_select 'select[name=?]', 'issue[done_ratio]'
      assert_select 'input[name=?][value=?]', 'issue[custom_field_values][2]', 'Default string'
      assert_select 'input[name=?]', 'issue[watcher_user_ids][]'
    end

    # Be sure we don't display inactive IssuePriorities
    assert ! IssuePriority.find(15).active?
    assert_select 'select[name=?]', 'issue[priority_id]' do
      assert_select 'option[value="15"]', 0
    end
=end
  end

  def test_get_new_with_list_custom_field
=begin
    @request.session[:user_id] = 2
    get :new, :params => {
        :project_id => 1,
        :tracker_id => 1
      }
    assert_response :success

    assert_select 'select.list_cf[name=?]', 'issue[custom_field_values][1]' do
      assert_select 'option', 4
      assert_select 'option[value=MySQL]', :text => 'MySQL'
    end
=end
  end

  def test_get_new_with_multi_custom_field
=begin
    field = IssueCustomField.find(1)
    field.update_attribute :multiple, true

    @request.session[:user_id] = 2
    get :new, :params => {
        :project_id => 1,
        :tracker_id => 1
      }
    assert_response :success

    assert_select 'select[name=?][multiple=multiple]', 'issue[custom_field_values][1][]' do
      assert_select 'option', 3
      assert_select 'option[value=MySQL]', :text => 'MySQL'
    end
    assert_select 'input[name=?][type=hidden][value=?]', 'issue[custom_field_values][1][]', ''
=end
  end

  def test_post_create
=begin
    @request.session[:user_id] = 2
    assert_difference 'Issue.count' do
      assert_no_difference 'Journal.count' do
        post :create, :params => {
            :project_id => 1,
            :issue => {
              :tracker_id => 3,
              :status_id => 2,
              :subject => 'This is the test_new issue',
              :description => 'This is the description',
              :priority_id => 5,
              :start_date => '2010-11-07',
              :estimated_hours => '',
              :custom_field_values => {
              '2' => 'Value for field 2'}
            }
          }
      end
    end
    assert_redirected_to :controller => 'issues', :action => 'show', :id => Issue.last.id

    issue = Issue.find_by_subject('This is the test_new issue')
    assert_not_nil issue
    assert_equal 2, issue.author_id
    assert_equal 3, issue.tracker_id
    assert_equal 2, issue.status_id
    assert_equal Date.parse('2010-11-07'), issue.start_date
    assert_nil issue.estimated_hours
    v = issue.custom_values.where(:custom_field_id => 2).first
    assert_not_nil v
    assert_equal 'Value for field 2', v.value
=end
  end

  def test_post_create_without_custom_fields_param
=begin
    @request.session[:user_id] = 2
    assert_difference 'Issue.count' do
      post :create, :params => {
          :project_id => 1,
          :issue => {
            :tracker_id => 1,
            :subject => 'This is the test_new issue',
            :description => 'This is the description',
            :priority_id => 5
          }
        }
    end
    assert_redirected_to :controller => 'issues', :action => 'show', :id => Issue.last.id
=end
  end

  def test_post_create_with_multi_custom_field
=begin
    field = IssueCustomField.find_by_name('Database')
    field.update_attribute(:multiple, true)

    @request.session[:user_id] = 2
    assert_difference 'Issue.count' do
      post :create, :params => {
          :project_id => 1,
          :issue => {
            :tracker_id => 1,
            :subject => 'This is the test_new issue',
            :description => 'This is the description',
            :priority_id => 5,
            :custom_field_values => {
            '1' => ['', 'MySQL', 'Oracle']}
          }
        }
    end
    assert_response 302
    issue = Issue.order('id DESC').first
    assert_equal ['MySQL', 'Oracle'], issue.custom_field_value(1).sort
=end
  end

  def test_post_create_with_empty_multi_custom_field
=begin
    field = IssueCustomField.find_by_name('Database')
    field.update_attribute(:multiple, true)

    @request.session[:user_id] = 2
    assert_difference 'Issue.count' do
      post :create, :params => {
          :project_id => 1,
          :issue => {
            :tracker_id => 1,
            :subject => 'This is the test_new issue',
            :description => 'This is the description',
            :priority_id => 5,
            :custom_field_values => {
            '1' => ['']}
          }
        }
    end
    assert_response 302
    issue = Issue.order('id DESC').first
    assert_equal [''], issue.custom_field_value(1).sort
=end
  end


  def test_create_should_validate_required_list_fields
=begin
    cf1 = IssueCustomField.create!(:name => 'Foo', :field_format => 'list', :is_for_all => true, :tracker_ids => [1, 2], :multiple => false, :possible_values => ['a', 'b'])
    cf2 = IssueCustomField.create!(:name => 'Bar', :field_format => 'list', :is_for_all => true, :tracker_ids => [1, 2], :multiple => true, :possible_values => ['a', 'b'])
    WorkflowPermission.delete_all
    WorkflowPermission.create!(:old_status_id => 1, :tracker_id => 2, :role_id => 1, :field_name => cf1.id.to_s, :rule => 'required')
    WorkflowPermission.create!(:old_status_id => 1, :tracker_id => 2, :role_id => 1, :field_name => cf2.id.to_s, :rule => 'required')
    @request.session[:user_id] = 2

    assert_no_difference 'Issue.count' do
      post :create, :params => {
          :project_id => 1,
          :issue => {
            :tracker_id => 2,
            :status_id => 1,
            :subject => 'Test',
            :start_date => '',
            :due_date => '',
            :custom_field_values => {
              cf1.id.to_s => '', cf2.id.to_s => ['']
            }

          }
        }
      assert_response :success
    end

    assert_select_error /Foo cannot be blank/i
    assert_select_error /Bar cannot be blank/i
=end
  end

  def test_get_edit
=begin
    @request.session[:user_id] = 2
    get :edit, :params => {
        :id => 1
      }
    assert_response :success

    assert_select 'select[name=?]', 'issue[project_id]'
    # Be sure we don't display inactive IssuePriorities
    assert ! IssuePriority.find(15).active?
    assert_select 'select[name=?]', 'issue[priority_id]' do
      assert_select 'option[value="15"]', 0
    end
=end
  end

  def test_get_edit_with_params
=begin
    @request.session[:user_id] = 2
    get :edit, :params => {
        :id => 1,
        :issue => {
          :status_id => 5,
          :priority_id => 7
        },
        :time_entry => {
          :hours => '2.5',
          :comments => 'test_get_edit_with_params',
          :activity_id => 10
        }
      }
    assert_response :success

    assert_select 'select[name=?]', 'issue[status_id]' do
      assert_select 'option[value="5"][selected=selected]', :text => 'Closed'
    end

    assert_select 'select[name=?]', 'issue[priority_id]' do
      assert_select 'option[value="7"][selected=selected]', :text => 'Urgent'
    end

    assert_select 'input[name=?][value="2.50"]', 'time_entry[hours]'
    assert_select 'select[name=?]', 'time_entry[activity_id]' do
      assert_select 'option[value="10"][selected=selected]', :text => 'Development'
    end
    assert_select 'input[name=?][value=test_get_edit_with_params]', 'time_entry[comments]'
=end
  end

  def test_get_edit_with_multi_custom_field
=begin
    field = CustomField.find(1)
    field.update_attribute :multiple, true
    issue = Issue.find(1)
    issue.custom_field_values = {1 => ['MySQL', 'Oracle']}
    issue.save!

    @request.session[:user_id] = 2
    get :edit, :params => {
        :id => 1
      }
    assert_response :success

    assert_select 'select[name=?][multiple=multiple]', 'issue[custom_field_values][1][]' do
      assert_select 'option', 3
      assert_select 'option[value=MySQL][selected=selected]'
      assert_select 'option[value=Oracle][selected=selected]'
      assert_select 'option[value=PostgreSQL]:not([selected])'
    end
=end
  end

  def test_update_form_for_existing_issue
=begin
    @request.session[:user_id] = 2
    patch :edit, :params => {
        :id => 1,
        :issue => {
          :tracker_id => 2,
          :subject => 'This is the test_new issue',
          :description => 'This is the description',
          :priority_id => 5
        }
      },
      :xhr => true
    assert_response :success
    assert_equal 'text/javascript', response.content_type

    assert_include 'This is the test_new issue', response.body
=end
  end

  def test_update_form_should_keep_category_with_same_when_changing_project
=begin
    source = Project.generate!
    target = Project.generate!
    source_category = IssueCategory.create!(:name => 'Foo', :project => source)
    target_category = IssueCategory.create!(:name => 'Foo', :project => target)
    issue = Issue.generate!(:project => source, :category => source_category)

    @request.session[:user_id] = 1
    patch :edit, :params => {
        :id => issue.id,
        :issue => {
          :project_id => target.id,
          :category_id => source_category.id
        }
      }
    assert_response :success

    assert_select 'select[name=?]', 'issue[category_id]' do
      assert_select 'option[value=?][selected=selected]', target_category.id.to_s
    end
=end
  end

  def test_put_update_with_custom_field_change
=begin
    @request.session[:user_id] = 2
    issue = Issue.find(1)
    assert_equal '125', issue.custom_value_for(2).value

    with_settings :notified_events => %w(issue_updated) do
      assert_difference('Journal.count') do
        assert_difference('JournalDetail.count', 3) do
          put :update, :params => {
              :id => 1,
              :issue => {
                :subject => 'Custom field change',
                :priority_id => '6',
                :category_id => '1', # no change
                :custom_field_values => { '2' => 'New custom value' }
              }
            }
        end
      end
    end
    assert_redirected_to :action => 'show', :id => '1'
    issue.reload
    assert_equal 'New custom value', issue.custom_value_for(2).value

    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    assert_mail_body_match "Searchable field changed from 125 to New custom value", mail
=end
  end

  def test_put_update_with_multi_custom_field_change
=begin
    field = CustomField.find(1)
    field.update_attribute :multiple, true
    issue = Issue.find(1)
    issue.custom_field_values = {1 => ['MySQL', 'Oracle']}
    issue.save!

    @request.session[:user_id] = 2
    assert_difference('Journal.count') do
      assert_difference('JournalDetail.count', 3) do
        put :update, :params => {
            :id => 1,
            :issue => {
              :subject => 'Custom field change',
              :custom_field_values => {
                '1' => ['', 'Oracle', 'PostgreSQL']
              }

            }
          }
      end
    end
    assert_redirected_to :action => 'show', :id => '1'
    assert_equal ['Oracle', 'PostgreSQL'], Issue.find(1).custom_field_value(1).sort
=end
  end
end
