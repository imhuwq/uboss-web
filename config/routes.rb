require 'sidekiq/web'
require 'okay_responder'

Rails.application.routes.draw do

  mount OkayResponder.new, at: "__upyun_uploaded"
  mount ChinaCity::Engine => '/china_city'

  devise_for :user, path: '/', controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  patch 'set_password', to: 'accounts#set_password'
  get 'set_password', to: 'accounts#new_password'

  get 'sharing/product_node', to: 'sharing#product_node', as: :get_product_sharing
  get 'sharing/seller_node', to: 'sharing#seller_node', as: :get_seller_sharing
  get 'sharing/:code', to: 'sharing#show', as: :sharing
  get 'maker_qrcode', to: 'home#maker_qrcode', as: :maker_qrcode

  get 'service_centre_consumer', to: 'home#service_centre_consumer'
  get 'service_centre_agent', to: 'home#service_centre_agent'
  get 'service_centre_tutorial', to: 'home#service_centre_tutorial'
  get 'about', to: 'home#about_us'
  get 'lady', to: 'home#lady'
  get 'maca', to: 'home#maca'
  get 'snacks', to: 'home#snacks'
  get 'agreements/seller'
  get 'agreements/maker'
  get 'agreements/register'

  post 'mobile_captchas/create', to: 'mobile_captchas#create'
  get  'mobile_captchas/send_with_captcha', to: 'mobile_captchas#send_with_captcha'

  resources :stores, only: [:show] do
    get :hots, :favours, on: :member
  end
  resources :orders, only: [:new, :create, :show] do
    get 'received', on: :member
    get 'pay_complete', on: :member
    get 'cancel', on: :member
    resource :charge, only: [:create]
    resources :pay,    only: [:index]
  end
  resources :products, only: [:index, :show] do
    member do
      patch :switch_favour
    end
    post :democontent,  on: :collection
  end
  resources :evaluations do
  end
  resource :withdraw_records, only: [:show, :new, :create] do
    get :success, on: :member
  end
  resource :account, only: [:show, :edit, :update] do
    get :settings,         :edit_password,     :reset_password,
        :orders,           :binding_agent, :invite_seller,
        :edit_seller_histroy, :edit_seller_note, :seller_agreement,
        :merchant_confirm,    :binding_successed, :maker_qrcode
    post :send_message
    put :bind_agent, :bind_seller, :update_histroy_note
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
  resources :privilege_cards, only: [:show, :index] do
    collection do
      patch :set_privilege_rate
      get :edit_rate
    end
  end
  resources :sellers, only: [:new, :create, :update]
  resources :carts, only: [:index] do
    collection do
      post :checkout
      post :delete_all
      post :delete_item
      post :change_item_count
      post :items_select
    end
  end
  resources :cart_items, only: [:create, :destroy]

  namespace :api do
    namespace :v1 do
      post 'login', to: 'sessions#create'
      resources :mobile_captchas, only: [:create]
      resource :account, only: [] do
        patch :update_password
        get :orders, :privilege_cards
      end
    end
  end

  authenticate :user, lambda { |user| user.admin? } do
    namespace :admin do
      resources :carriage_templates do
        member do
          get :copy
        end
      end

      get '/select_carriage_template', to: 'products#select_carriage_template'

      resources :expresses do
        member do
          get :set_common
          get :cancel_common
        end
      end

      resources :products, except: [:destroy] do
        member do
          patch :change_status
          get :pre_view
          patch :switch_hot_flag
        end
      end
      resources :orders, except: [:destroy] do
        patch :set_express, on: :member
        get :ship, on: :member
      end
      resources :sharing_incomes, only: [:index, :show, :update]
      resources :withdraw_records, only: [:index, :show, :new, :create] do
        get :generate_excel, on: :collection
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
      resources :sellers, only: [:index, :show, :edit, :update] do
        post :update_service_rate, on: :collection
      end
      resource :account, only: [:edit, :show, :update] do
        get :password, on: :member
        get :binding_agent
        patch :binding_agent, to: 'accounts#bind_agent'
        patch :password, to: 'accounts#update_password'
      end
      resources :transactions, only: [:index]
      resources :bank_cards, only: [:index, :new, :edit, :create, :update, :destroy]

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
