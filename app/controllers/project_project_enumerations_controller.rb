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

class ProjectProjectEnumerationsController < ApplicationController
  menu_item :issues
  model_object ProjectEnumeration

  before_action :find_model_object, :except => [:new, :create]
  before_action :find_project_from_association, :except => [:new, :create]
  before_action :find_project_by_project_id, :only => [:new, :create]
  before_action :find_custom_field_by_custom_field_id, :only => [:new, :create]

  before_action :authorize


  # TODO create API views
  accept_api_auth :create, :update, :destroy

  helper :projects


  def new
    @project_enumeration = ProjectEnumeration.new(
        :project_id => @project.id,
        :custom_field_id => @custom_field.id
      )

    @project_enumeration.safe_attributes = params[:project_enumeration]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @project_enumeration = ProjectEnumeration.new(
        :project_id => @project.id,
      )

    if params[:project_enumeration]
      attributes = params[:project_enumeration].dup
      attributes.delete('sharing') unless attributes.nil? || @project_enumeration.allowed_sharings.include?(attributes['sharing'])

      @project_enumeration.custom_field_id = @custom_field.id

      @project_enumeration.safe_attributes = attributes
    end

    if request.post?
      if @project_enumeration.save
        respond_to do |format|
          format.html do
            flash[:notice] = l(:notice_successful_create)
            redirect_back_or_default settings_project_path(@project, :tab => 'project_enumerations')
          end
          format.js
          format.api do
            render :action => 'show', :status => :created, :location => project_enumeration_url(@project_enumeration)
          end
        end
      else
        respond_to do |format|
          format.html { render :action => 'new' }
          format.js   { render :action => 'new' }
          format.api  { render_validation_errors(@project_enumeration) }
        end
      end
    end
  end

  def edit
  end

  def update
    if params[:project_enumeration]
      attributes = params[:project_enumeration].dup
      attributes.delete('sharing') unless @project_enumeration.allowed_sharings.include?(attributes['sharing'])

      #@project_enumeration.custom_field_id = params[:custom_field_id]

      @project_enumeration.safe_attributes = attributes
      if @project_enumeration.save
        respond_to do |format|
          format.html {
            flash[:notice] = l(:notice_successful_update)
            redirect_back_or_default settings_project_path(@project, :tab => 'project_enumerations')
          }
          format.api  { render_api_ok }
        end
      else
        respond_to do |format|
          format.html { render :action => 'edit' }
          format.api  { render_validation_errors(@project_enumeration) }
        end
      end
    end
  end

  def destroy
    @project_enumeration.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_successful_delete)
        redirect_back_or_default settings_project_path(@project, :tab => 'project_enumerations')
      }
      format.api  { render_api_ok }
    end
  end


  protected

  def find_model_object
    model = self.class.model_object
    if model
      @object = @project_enumeration = model.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_custom_field_by_custom_field_id
    @custom_field = CustomField.find(params[:custom_field_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
