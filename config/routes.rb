Podup::Application.routes.draw do
  resources :pods do
    collection do
      get :own
    end
    get :switch_maintenance
  end
  
  match 'users/edit' => redirect('/user/edit')
  devise_for :users, :controllers => { :registrations => "registrations"}
  resources :users, :only => [:show], :as => 'public_user'
  resource :user, :only => [:edit, :update, :destroy]
  
  root :to => "pods#index"
end
