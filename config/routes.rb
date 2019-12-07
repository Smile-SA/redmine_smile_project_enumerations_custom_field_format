resources :projects do
  resource :project_enumerations, :controller => 'project_project_enumerations', :only => [:new, :edit] do
    collection do
      get 'index'
    end

    member do
      post 'create',     :as => 'create'
      put 'update',      :as => 'update'
      put 'update_each', :as => 'update_each'
      delete 'destroy',  :as => 'destroy'
    end
  end

  resource :project_list_values, :controller => 'project_project_list_values', :only => [:new, :edit] do
    collection do
      get 'index'
    end

    member do
      post 'create',     :as => 'create'
      put 'update',      :as => 'update'
      put 'update_each', :as => 'update_each'
      delete 'destroy',  :as => 'destroy'
    end
  end
end
