Rails.application.routes.draw do

  namespace :admin do
  end

  namespace :admin do
    root 'home#index'
    resources :users do
    end
    resources :sessions do
      get :active_user,:try_to_reset_password,:reset_password, :on=>:collection
      post :send_reset_password_email, :on=>:collection
    end
  end

  root 'welcome#index'
end
