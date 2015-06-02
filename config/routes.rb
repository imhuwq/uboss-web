Rails.application.routes.draw do

  devise_for :user, controllers: { 
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  authenticate :user, lambda { |user| user.admin? } do
    namespace :admin do
      root 'dashboard#index'
    end
  end

  root 'home#index'
end
