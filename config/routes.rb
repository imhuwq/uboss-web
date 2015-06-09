Rails.application.routes.draw do

  devise_for :user, controllers: { 
    sessions: "users/sessions",
    passwords: "users/passwords",
  }


  authenticate :user, lambda { |user| user.admin? } do
    namespace :admin do
      resources :products, except: [:destroy] do
      end
      resources :orders, except: [:destroy] do
        patch :ship, on: :member
      end
      root 'dashboard#index'
    end
  end
  namespace :mobile do
    resources :products do
    end
  end
  match '/mobile', to: "mobile/products#index",via: [:get]
  root 'home#index'
end
