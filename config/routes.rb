Rails.application.routes.draw do

  devise_for :user, controllers: { 
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  namespace :admin do
    # root 'home#index'
    resources :users do
    end
    resources :products do
      post :add_avatar, :on=>:collection
    end
    resources :orders do
    end
    resources :sessions do
      get :active_user,:try_to_reset_password,:reset_password, :on=>:collection
      post :send_reset_password_email, :on=>:collection
    end
  end
  authenticate :user, lambda { |user| user.admin? } do
    namespace :admin do
      root 'dashboard#index'
    end
  end

  root 'home#index'
end
