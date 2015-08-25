require 'sidekiq/web'
require 'okay_responder'

Rails.application.routes.draw do
  mount OkayResponder.new, at: "__upyun_uploaded"

  devise_for :user, path: '/', controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  get 'set_password', to: 'accounts#new_password'
  patch 'set_password', to: 'accounts#set_password'
  get 'sharing/:code', to: 'sharing#show', as: :sharing
  get 'service_centre_consumer', to: 'home#service_centre_consumer'
  get 'service_centre_agent', to: 'home#service_centre_agent'
  get 'service_centre_tutorial', to: 'home#service_centre_tutorial'

  post 'mobile_auth_code/create', to: 'mobile_auth_code#create'

  resources :stores, only: [:show]
  resources :orders, only: [:new, :create, :show] do
    get 'received', on: :member
    get 'pay_complete', on: :member
    resource :charge, only: [:create]
  end
  resources :products do
    post :save_mobile, :democontent,  on: :collection
  end
  resources :evaluations do
  end
  resource :withdraw_records, only: [:show, :new, :create] do
    get :success, on: :member
  end
  resource :account, only: [:show, :edit, :update] do
    get :settings,         :edit_password,     :reset_password,
        :orders,           :new_agent_binding, :invite_seller,
        :edit_seller_histroy, :edit_seller_note, :seller_agreement,
        :merchant_confirm,    :binding_successed

    put :binding_agent, :send_message, :update_histroy_note
    patch :merchant_confirm, to: 'accounts#merchant_confirmed'
    patch :password, to: 'accounts#update_password'
    resources :user_addresses, except: [:show]
  end
  resource :pay_notify, only: [] do
    collection do
      post :wechat_notify
      post :wechat_alarm
    end
  end
  resources :privilege_cards, only: [:show, :index, :update]
  resources :sellers, only: [:new, :create, :update]

  authenticate :user, lambda { |user| user.admin? } do
    namespace :admin do
      resources :products, except: [:destroy] do
        get :change_status, :pre_view, on: :member
      end
      resources :orders, except: [:destroy] do
        patch :ship, on: :member
      end
      resources :sharing_incomes, only: [:index, :show, :update]
      resources :withdraw_records, only: [:index, :show, :new, :create] do
        member do
          patch :processed
          patch :close
        end
      end
      resources :personal_authentications, only: [:index]
      resources :enterprise_authentications, only: [:index]
      resources :users, except: [:destroy] do
        resource :personal_authentication do
          get :change_status, on: :member
        end
        resource :enterprise_authentication do
          get :change_status, on: :member
        end
      end
      resources :agents, except: [:new, :edit, :update, :destroy] do
      end
      resources :sellers, except: [:new, :edit, :update, :destroy] do
        post :update_service_rate, on: :collection
        get  :withdraw_records, on: :member
        resources :income_reports, only: [:index, :show] do
          get :details, on: :collection
        end
      end
      resource :account, only: [:edit, :show, :update] do
        get :password, on: :member
        get :binding_agent
        patch :binding_agent, to: 'accounts#bind_agent'
        patch :password, to: 'accounts#update_password'
      end
      resources :transactions, only: [:index]
      resources :income_reports, only: [:index, :show]
      resources :bank_cards, only: [:index, :show, :new, :create, :destroy]

      get '/data', to: 'data#index'
      get '/backend_status', to: 'dashboard#backend_status'

      root 'dashboard#index'
    end
    mount RedactorRails::Engine => '/redactor_rails'
  end

  authenticate :user, lambda { |user| user.admin? && user.is_role?('super_admin') } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root 'home#index'

end
