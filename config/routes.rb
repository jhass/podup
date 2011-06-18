Podup::Application.routes.draw do
  resources :pods
  
  devise_for :users
  
  root :to => "pods#index"
end
