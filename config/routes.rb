resources :projects do
  resource :project_enumerations, :controller => 'project_project_enumerations', :only => [:new, :create, :edit, :update, :destroy]
end
