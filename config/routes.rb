require 'sidekiq/web'
require 'okay_responder'

Rails.application.routes.draw do

  mount WeixinRailsMiddleware::Engine, at: "/wx_api"
  mount OkayResponder.new, at: "__upyun_uploaded"
  mount ChinaCity::Engine => '/china_city'

  devise_for :user, path: '/', controllers: {
    confirmations: "users/confirmations",
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
  get 'qrcode', to: 'home#qrcode', as: :request_qrcode
  get 'ls_game', to: 'home#hongbao_game'
  get 'store_qrcode_img', to: 'home#store_qrcode_img'

  get 'service_centre_consumer', to: 'home#service_centre_consumer'
  get 'service_centre_agent', to: 'home#service_centre_agent'
  get 'service_centre_tutorial', to: 'home#service_centre_tutorial'
  get 'about', to: 'home#about_us'
  get 'lady', to: 'home#lady'
  get 'city', to: 'home#city'
  get 'maca', to: 'home#maca'
  get 'snacks', to: 'home#snacks'
  get 'agreements/seller'
  get 'agreements/maker'
  get 'agreements/register'

  post 'mobile_captchas/create', to: 'mobile_captchas#create'
  get  'mobile_captchas/send_with_captcha', to: 'mobile_captchas#send_with_captcha'

  resources :pages, only: [] do
    collection do
      get :bonus_invite
    end
  end

  resources :homepage, only: [:show] do
    member do
      get :recommend_products
      get :recommend_stores
    end
  end

  resources :recommends, only: [:create, :destroy]

  resources :bonus, only: [:create] do
    post :invited, on: :collection
  end
  resources :stores, only: [:index, :show] do
    get :hots, :favours, on: :member
    resources :categories, only: [:show]
  end
  resources :orders, only: [:new, :create, :show] do
    get 'received', on: :member
    get 'pay_complete', on: :member
    get 'cancel', on: :member
    post 'change_address', on: :collection
    #resource :charge, only: [:create]
  end
  resources :service_orders, only: [:new, :create, :show] do
    get 'cancel', on: :member
  end

  resources :order_items, only: [] do
    resources :order_item_refunds do
      get  :apply_uboss, on: :member
      get  :close, on: :member
      get  :service_select,   on: :collection
      resources :sales_returns, only:[:new, :create, :edit, :update]
      resources :refund_messages, only: [:new, :create]
    end
  end

  resources :charges, only: [:show] do
    get 'payments',     on: :collection
    get 'pay_complete', on: :member
  end

  resources :products, only: [:index, :show] do
    member do
      patch :switch_favour
    end
    get :get_sku, on: :collection
    post :democontent,  on: :collection
  end
  resources :service_products, only: [:index, :show] do
    member do
      patch :switch_favour
    end
  end
  resources :evaluations do
    get :append, on: :member
  end
  resource :withdraw_records, only: [:show, :new, :create] do
    get :success, on: :member
  end

  resources :service_stores, only: [:index, :show] do
    get :verify_detail, on: :member
    get :share, on: :member
    post :verify, on: :member
  end

  resource :chat, only: [:show] do
    get :token, :user_info, :check_user_online
    get 'conversations/:conversation_id', to: 'chats#conversion', as: :conversation
  end
  resource :account, only: [:show, :edit, :update] do
    get :settings, :edit_password, :orders,
        :service_orders, :binding_agent, :invite_seller,
        :edit_seller_histroy, :edit_seller_note, :seller_agreement,
        :merchant_confirm,    :binding_successed,
        :income, :service_orders, :bonus_benefit
    post :send_message
    put :bind_agent, :bind_seller, :update_histroy_note
    patch :merchant_confirm, to: 'accounts#merchant_confirmed'
    patch :password, to: 'accounts#update_password'
    resources :user_addresses, except: [:show]
    resources :verify_codes, only: [:index, :show] do
      get :lotteries, on: :collection
      get :lottery_detail, on: :collection
    end
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
    end
  end
  resources :cart_items, only: [:index, :create]
  resources :promotion_activities, only: [:show] do
    get :live_draw,  on: :member
    get :share_draw, on: :member
  end

  namespace :api do
    namespace :v1 do
      namespace :admin do
        resources :carriage_templates, only: [:index, :show]
        resources :service_products, only: [:index, :create, :show] do
          patch :change_status, on: :member
        end
        resources :service_stores, only: [:create] do
          post :verify, on: :collection
        end
        resources :products, only: [:index, :show, :create] do
          member do
            get :inventories, :detail
          end
        end
        post 'verify_codes/verify', to: 'verify_codes#verify'
        get 'verify_history/:date', to: 'verify_codes#verify_history'
        get 'receipt_history/:date', to: 'verify_codes#receipt_history'
        get 'yesterday_income_and_balance', to: 'incomes#yesterday_income_and_balance'
        get 'income/:date', to: 'incomes#the_income'
        get 'balance', to: 'incomes#balance'
        resources :bank_cards, only: [:index, :create, :destroy] do
          get 'get_default_bankcard', on: :collection
        end
        resources :withdraw_records, only: [:index, :create]
        resource :service_store, only: [:show, :update] do
          post :create_advertisement
          patch :update_advertisement
          delete 'remove_advertisement/:id', to: 'service_stores#remove_advertisement'
          get 'get_id', to: 'service_stores#get_id'
        end
      end
      resources :service_stores, only: [:create] do
        get :total_verify_detail, :today_verify_detail
      end

      post 'login', to: 'sessions#create'
      resources :mobile_captchas, only: [:create]
      resources :users, only: [:show]
      resources :stores, only: [:show]
      resource :account, only: [:show] do
        patch :update_password, :become_seller
        get :orders, :privilege_cards
      end
      resource :chat, only: [] do
        get :token, :check_user_online
      end
    end
  end

  authenticate :user, lambda { |user| user.admin? } do
    namespace :admin do
      resources :wechat_accounts do
        post :set_menu, on: :member
      end
      %w(suppliers sellers).each do |mod|
        scope path: mod, as: mod do
          resources :carriage_templates do
            member do
              get :copy
            end
          end
        end
      end

      resources :agencies, only: [:index, :new] do
        post :build_cooperation_with_auth_code, on: :collection
        post :build_cooperation_with_agency_id, on: :collection
        delete :end_cooperation, on: :member
      end

      get '/sellers/valid_agent_products', to: 'agency_products#valid_agent_products'
      post '/store_supplier_product/:id', to: 'agency_products#store_supplier_product', as: :store_supplier_product
      post '/list_supplier_product/:id', to: 'agency_products#list_supplier_product', as: :list_supplier_product

      get '/select_carriage_template', to: 'products#select_carriage_template'

      get '/refresh_carriage_template', to: 'products#refresh_carriage_template'

      resources :service_stores, only: [:edit, :update] do
        collection do
          get :income_detail
          get :statistics
          get :create_advertisement
          post :update_advertisement_img
          get :remove_advertisement_item
        end
      end

      resources :verify_codes, only: [:index] do
        collection do
          get :statistics
          post :verify
        end
      end

      resources :evaluations, only: [:index, :destroy] do
        collection do
          get :statistics
        end
      end

      resources :expresses do
        member do
          get :set_common
          get :cancel_common
        end
      end

      resource :supplier_store, except: [:show] do
        get :edit_info
        patch :update_info
        patch :update_name
        patch :update_short_description
        patch :update_store_cover
        post :update_store_cover
      end

      get '/supplier_stores/:id', to: 'supplier_stores#show', as: :show_supplier_store

      resources :supplier_products, except: [:destroy] do
        member do
          patch :toggle_supply_status
        end
      end

      resources :products, except: [:destroy] do
        member do
          patch :change_status
          patch :delete_agency_product
          get :pre_view
          patch :switch_hot_flag
        end
      end
      resources :service_products, except: [:destroy] do
        member do
          patch :change_status
          get :pre_view
        end
      end

      resources :promotion_activities, except: [:destroy] do
        member do
          patch :change_status
        end
      end

      resources :orders, except: [:destroy] do
        patch :set_express, on: :member
        patch :change_ship_price, on: :member
        get :close, on: :member
        post :batch_shipments, on: :collection
        post :select_orders, on: :collection
      end
      resources :purchase_orders, only: [:index, :show] do
        member do
          patch :delivery
        end
      end
      resources :order_items, only: [] do
        resources :order_item_refunds, only: [:index] do
          get  :approved_refund,  on: :member
          get  :confirm_received, on: :member
          get  :uboss_cancel,     on: :member
          get  :applied_uboss,    on: :member
          post :approved_return,  on: :member
          post :declined_refund,  on: :member
          post :declined_return,  on: :member
          post :declined_receive, on: :member
          post :refund_message,   on: :member
        end
        resources :refund_messages, only: [:create]
      end
      resources :sharing_incomes, only: [:index, :show, :update]
      resources :withdraw_records, only: [:index, :show, :new, :create] do
        get :generate_excel, on: :collection
        member do
          patch :processed, :finish, :close, :query_wx
        end
      end
      resources :personal_authentications, only: [:index]
      resources :enterprise_authentications, only: [:index]
      resources :certifications, only: [:index] do
        collection do
          get :persons
          get :enterprises
          get :city_managers
        end
        put :change_status, on: :member
      end
      resources :users, except: [:destroy] do
        get :search
        resource :personal_authentication
        resource :enterprise_authentication
        resource :city_manager_authentication
      end
      resources :agents, except: [:new, :edit, :update, :destroy] do
      end
      resources :city_managers, only: [:index] do
        collection do
          get :added
          get :revenues
          get :cities
        end
        member do
          put :bind
          put :unbind
        end
      end
      resources :sellers, only: [:index, :show, :edit, :update] do
        patch :update_service_rate, on: :member
        get :my_suppliers, on: :collection
      end

      resource :account, only: [:edit, :show, :update] do
        get :password, on: :member
        get :binding_agent, :binding_email, :binding_mobile
        patch :binding_agent, to: 'accounts#bind_agent'
        patch :password, to: 'accounts#update_password'
        patch :bind_email, :bind_mobile
      end
      resources :transactions, only: [:index]
      resources :bank_cards, only: [:index, :new, :edit, :create, :update, :destroy]
      resources :user_addresses do
        get :change_default_address, on: :member
      end

      get '/data', to: 'data#index'
      get '/backend_status', to: 'dashboard#backend_status'

      root 'dashboard#index'

      resources :categories, except: [:show] do
        post :update_categories, on: :collection
        post :update_category_name,  on: :member
        post :update_category_img, on: :collection
      end

      resources :stores, only: [:show] do
        post :update_store_name, :update_store_short_description,
          :update_store_cover, on: :member
        post :update_advertisement_img, :update_advertisement_order, on: :collection
        get :create_advertisement, :add_category, :get_category_img, :edit,  on: :collection
        get :new_advertisement, :remove_advertisement, :show_category, :get_advertisement_items, :remove_advertisement_item, :remove_category_item, on: :collection
      end
      resources :platform_advertisements do
        patch :change_status, on: :member
      end
    end
    mount RedactorRails::Engine => '/redactor_rails'
  end

  authenticate :user, lambda { |user| user.admin? && user.is_role?('super_admin') } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root 'home#index'

  get '/discourse/sso', to: 'discourse_sso#sso'
end
