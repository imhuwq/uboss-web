require 'sidekiq/web'

Rails.application.routes.draw do

  devise_for :user, controllers: {
    sessions: "users/sessions",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  get 'wxpay/test/:id', to: 'orders#show', as: :test_wxpay

  resources :orders, only: [:new, :create, :show] do
    get :new_mobile, on: :collection
    get 'received', on: :member
    get 'pay_complete', on: :member
    resource :charge, only: [:create]
  end
  resources :products do
    post :save_mobile, on: :collection
  end
  resource :evaluations do
  end
  resource :account, only: [:show, :edit, :update] do
    resources :user_addresses, except: [:show]
  end
  resource :pay_notify, only: [] do
    collection do
      post :wechat_notify
      post :wechat_alarm
    end
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
      resource :account, only: [:edit, :show, :update] do
        get :password, on: :member
        patch :password, to: 'accounts#update_password'
      end

      get '/data', to: 'data#index'

      root 'dashboard#index'
    end
    mount RedactorRails::Engine => '/redactor_rails'
  end

  authenticate :user, lambda { |user| user.id == 1 } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root 'products#index'
  get 'sharing(.:code)' => 'sharing#show'

end
