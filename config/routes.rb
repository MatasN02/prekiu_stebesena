Rails.application.routes.draw do
  resources :customer_orders
  devise_for :users

  namespace :admin do
    resources :orders, only: [:index, :update]
    resources :anomalies, only: [:index, :update] do
      collection { post :scan }
    end
    resources :warehouse_anomalies, only: [:update]
  end

  resources :warehouse_orders, only: [:index, :show], param: :number

  get "track/:token", to: "tracking#show", as: :tracking
  mount LetterOpenerWeb::Engine, at: "/letters" if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check
  root "customer_orders#index"
end