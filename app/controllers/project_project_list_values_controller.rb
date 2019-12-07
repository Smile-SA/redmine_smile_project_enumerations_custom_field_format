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

class ProjectProjectListValuesController < ApplicationController
  menu_item :settings
  model_object ProjectEnumeration

  before_action :find_model_object, :except => [:index, :new, :create, :update_each]
  before_action :find_project_from_association, :except => [:index, :new, :create, :update_each]
  before_action :find_project_by_project_id, :only => [:index, :new, :create, :update_each]
  before_action :find_custom_field_by_custom_field_id, :only => [:index, :new, :create, :update_each]

  before_action :authorize


  # TODO create API views
  accept_api_auth :create, :update, :destroy

  helper :projects, :custom_fields
  helper_method :project_list_value_custom_field_title


  def index
    find_project_list_values_for_custom_field(@custom_field.id)

    @project_list_value = ProjectEnumeration.new(
        :project_id => @project.id,
        :custom_field_id => @custom_field.id
      )
  end

  def new
    @project_list_value = ProjectEnumeration.new(
        :project_id => @project.id,
        :custom_field_id => @custom_field.id
      )

    @project_list_value.safe_attributes = params[:project_list_value]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    find_project_list_values_for_custom_field(@custom_field.id)

    if @project_list_values.is_a?(Array)
      max_position = 0
    else
      max_position = @project_list_values.maximum(:position)
    end

    max_position ||= 0
    max_position += 1

    @project_list_value = ProjectEnumeration.new(
        :project_id => @project.id,
        :custom_field_id => @custom_field.id,
        :position => max_position
      )

    if params[:project_list_value]
      attributes = params[:project_list_value].dup
      attributes.delete('sharing') unless attributes.nil? || @project_list_value.allowed_sharings.include?(attributes['sharing'])

      @project_list_value.safe_attributes = attributes
    end

    if request.post?
      if @project_list_value.save
        respond_to do |format|
          format.html do
            flash[:notice] = l(:notice_successful_create)
            redirect_back_or_default settings_project_path(@project, :tab => 'project_list_values')
          end
          format.js {
            find_project_list_values_for_custom_field(@custom_field.id)
            render :action => 'create'
          }
          format.api do
            render :action => 'show', :status => :created, :location => project_list_value_url(@project_list_value)
          end
        end
      else
        respond_to do |format|
          format.html { render :action => 'new' }
          format.js   {
            find_project_list_values_for_custom_field(@custom_field.id)

            # Render errors to flash message
            error_msg = @project_list_value.errors.full_messages

            if error_msg.any?
              flash[:error] = error_msg.join('<br/>'.html_safe)
            end

            render :action => 'create'
          }
          format.api  { render_validation_errors(@project_list_value) }
        end
      end
    end
  end

  def edit
  end

  def update
    if params[:project_list_value]
      attributes = params[:project_list_value].dup
      attributes.delete('sharing') unless @project_list_value.allowed_sharings.include?(attributes['sharing'])

      @project_list_value.safe_attributes = attributes
      if @project_list_value.save
        respond_to do |format|
          format.html {
            flash[:notice] = l(:notice_successful_update)
            redirect_back_or_default settings_project_path(@project, :tab => 'project_list_values')
          }
          format.api  { render_api_ok }
        end
      else
        respond_to do |format|
          format.html { render :action => 'edit' }
          format.api  { render_validation_errors(@project_list_value) }
        end
      end
    end
  end

  def update_each
    project_shared_list_values = @project.shared_list_values.to_a
    saved = ProjectEnumeration.update_each(@project, update_each_params, project_shared_list_values)

    if saved
      flash[:notice] = l(:notice_successful_update)
    else
      # Render errors to flash message

      error_msg = []
      project_shared_list_values.each do |pe|
        pe.errors.full_messages.each do |m|
          error_msg << "#{pe.value} : #{m} (#{l(:field_position)} #{pe.position})"
        end
      end

      if error_msg.any?
        flash[:error] = error_msg.join('<br/>'.html_safe)
      end
    end

    redirect_to :action => 'index', :custom_field_id => @custom_field.id
  end

  def destroy
    @project_list_value.destroy
    custom_field_id = @project_list_value.custom_field_id
    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_successful_delete)
        redirect_back_or_default project_project_list_values_path(@project, :custom_field_id => custom_field_id)
      }
      format.api  { render_api_ok }
      format.js {
        flash[:notice] = l(:notice_successful_delete)
        redirect_back_or_default project_project_list_values_path(@project, :custom_field_id => custom_field_id)
      }
    end
  end


protected

  def find_model_object
    model = self.class.model_object
    if model
      @object = @project_list_value = model.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_custom_field_by_custom_field_id
    @custom_field = CustomField.find(params[:custom_field_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project_list_values_for_custom_field(custom_field_id)
    list_value_custom_field_ids_enabled_on_project = CustomField.enabled_on_project(@project).where(:field_format => 'project_list_value').pluck(:id)

    if list_value_custom_field_ids_enabled_on_project.include?(custom_field_id)
      @project_list_values = ProjectEnumeration.where(:custom_field_id => custom_field_id).where(:project_id => @project.id).for_list_values.order_by_custom_field_then_position
    else
      @project_list_values = []
    end
  end

  def update_each_params
    # params.require(:project_list_values).permit(:value, :status, :sharing, :position) does not work here with param like this:
    # "project_list_values":{"0":{"name": ...}, "1":{"name...}}

    filtered_params = {}
    params[:project_list_values].each do |id, v|
      params_for_list_value = {}
      v.each do |id, v|
        next unless ['value', 'status', 'sharing', 'position'].include?(id)
        params_for_list_value[id] = v
      end

      filtered_params[id] = params_for_list_value
    end
=begin
    params.permit(:project_list_values => [:value, :status, :sharing, :position]).
      require(:project_list_values)
=end
    filtered_params
  end

  def project_list_value_custom_field_title(custom_field)
    items = []

    items << [l(:label_project_list_value_plural), settings_project_path(@project, :tab => 'project_list_values')]
    items << (custom_field.nil? || custom_field.new_record? ? l(:label_custom_field_new) : custom_field.name)

    helpers.title(*items)
  end
end
