Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      resource :onboarding, only: [ :show ], controller: "onboarding"

      namespace :onboarding do
        resource :welcome, only: [ :update ], controller: "welcome" do
          patch :skip, on: :member
        end
        resource :lead_time, only: [ :update ], controller: "lead_time"
        resource :stock_days, only: [ :update ], controller: "stock_days"
        resource :forecasting_period, only: [ :update ], controller: "forecasting_period"
        resource :upload_pos, only: [ :update ], controller: "upload_pos" do
          patch :skip, on: :member
        end
        resource :match_suppliers, only: [ :update ], controller: "match_suppliers" do
          patch :skip, on: :member
        end
        resource :bundles, only: [ :update ], controller: "bundles" do
          patch :skip, on: :member
        end
        resource :set_integrations, only: [ :update ], controller: "set_integrations" do
          patch :skip, on: :member
        end

        resources :file_uploads, only: [ :create, :show ]
      end

      resources :integrations, only: [ :index, :create, :update, :destroy ]
      resources :vendors, only: [ :index, :create ]
      resources :products, only: [ :index ] do
        collection do
          patch :assign_vendors
        end
      end
    end
  end
end
