require 'sidekiq/web'

Rails.application.routes.draw do

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
  resource :evaluations do
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
      resources :sharing_incomes, only: [:index, :show, :update]
      resources :withdraw_records, only: [:index, :show, :update] do
        member do
          patch :processed
          patch :finish
          patch :close
        end
      end
      resources :users, except: [:destroy]
      get '/data', to: 'data#index'

      root 'dashboard#index'
    end
    mount RedactorRails::Engine => '/redactor_rails'
  end

  authenticate :user, lambda { |user| user.id == 1 } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get 'sharing' => 'sharing#index'
  root 'products#index'
end
