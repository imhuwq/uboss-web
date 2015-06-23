require 'sidekiq/web'

Rails.application.routes.draw do

  mount RedactorRails::Engine => '/redactor_rails'

  devise_for :user, controllers: {
    sessions: "users/sessions",
    passwords: "users/passwords",
  }

  resources :orders, only: [:new, :create, :show] do
    get 'pay', on: :member
  end
  resources :products do
    post :save_mobile, on: :collection
  end
  resource :charge, only: [:create] do
    collection do
      post 'pingpp_callback'
      get 'success'
      get 'failure'
    end
  end
  resource :account, only: [:show, :edit, :update] do
    resources :user_addresses, except: [:show]
  end

  authenticate :user, lambda { |user| user.admin? } do
    namespace :admin do
      resources :products, except: [:destroy] do
        get :change_status, :pre_view, on: :member
      end
      resources :orders, except: [:destroy] do
        patch :ship, on: :member
      end
      root 'dashboard#index'
    end

    mount Sidekiq::Web => '/sidekiq'
  end

  root 'home#index'
end
