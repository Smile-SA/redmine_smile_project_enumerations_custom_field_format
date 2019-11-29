resources :projects do
  resource :project_enumerations, :controller => 'project_project_enumerations', :only => [:new, :create, :edit, :update, :destroy]

  resource :project_list_values, :controller => 'project_project_list_values', :only => [:new, :create, :edit, :update, :destroy]
end
