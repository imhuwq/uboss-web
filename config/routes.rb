Rails.application.routes.draw do

  devise_for :user, controllers: { 
    sessions: "users/sessions",
    passwords: "users/passwords",
  }


  authenticate :user, lambda { |user| user.admin? } do
    namespace :admin do
      resources :products do
      end
      resources :orders 
      root 'dashboard#index'
    end
  end

  root 'home#index'
end
