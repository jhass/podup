Podup::Application.routes.draw do
  resources :pods, :only => [:index, :show]
  
  match 'users/edit' => redirect('/user/edit')
  devise_for :users, :controllers => { :registrations => "registrations"}
  resource :user, :only => [:edit, :update, :destroy] do
    resources :pods
  end
  resources :users, :only => [:show]
  
  root :to => "pods#index"
end
