Rails.application.routes.draw do
  root 'welcome#index'

  match '/admin', to: 'admin/main#index',via: :get
  namespace :admin do
    resources :users do
    end
    resources :sessions do
      get :active_user,:try_to_reset_password,:reset_password, :on=>:collection
      post :send_reset_password_email, :on=>:collection
    end
  end
end
