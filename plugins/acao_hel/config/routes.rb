Rails.application.routes.draw do
  namespace :ygg do
    namespace :acao do
      post 'password_recovery' => 'password_recovery#recover'
      get 'stats' => 'stats#all'
      post 'wol' => 'wol#wake'

      namespace :gate do
        post 'open'
        post 'event'
      end

      hel_resources :flights, controller: 'flight/rest' do
      end

      hel_resources :trailers, controller: 'trailer/rest' do
      end

      hel_resources :key_fobs, controller: 'key_fob/rest' do
        member do
          post :request_deletion
          post :replicas_force
        end
      end

      hel_resources :trackers, controller: 'tracker/rest' do
      end

      hel_resources :aircrafts, controller: 'aircraft/rest' do
        collection do
          get 'by_code/:id(.:format)' => :by_code
        end

        member do
          post :upload_photo
        end
      end

      hel_resources :aircraft_types, controller: 'aircraft_type/rest' do
      end

      hel_resources :pilots, controller: 'pilot/rest' do
      end

      hel_resources :meters, controller: 'meter/rest' do
      end

      hel_resources :meter_buses, controller: 'meter_bus/rest' do
      end

      hel_resources :timetable_entries, controller: 'timetable_entry/rest' do
      end

      hel_resources :pilots, controller: 'pilot/rest' do
      end

      hel_resources :airfields, controller: 'airfield/rest' do
      end

      hel_resources :radar_points, controller: 'radar_point/rest' do
        collection do
          get 'track/:year/:month/:day/:aircraft_id' => :track_day
          get 'track' => :track
        end
      end

      hel_resources :memberships, controller: 'membership/rest' do
        collection do
          get 'renew' => :renew_context
          post 'renew' => :renew_do
        end
      end

      hel_resources :licenses, controller: 'license/rest' do
      end

      hel_resources :fai_cards, controller: 'fai_card/rest' do
      end

      hel_resources :medicals, controller: 'medical/rest' do
      end

      hel_resources :service_types, controller: 'service_type/rest' do
      end

      hel_resources :roster_days, controller: 'roster_day/rest' do
      end

      hel_resources :days, controller: 'day/rest' do
        member do
          get :daily_form
        end
      end

      hel_resources :roster_entries, controller: 'roster_entry/rest' do
        collection do
          get 'status' => :get_status
          post 'get_policy' => :get_policy
        end

        member do
          post :offer
          post :offer_cancel
          post :offer_accept
        end
      end

      hel_resources :tow_roster_days, controller: 'tow_roster_day/rest' do
      end

      hel_resources :tow_roster_entries, controller: 'tow_roster_entry/rest' do
      end

      hel_resources :years, controller: 'year/rest' do
      end

      hel_resources :payments, controller: 'payment/basic' do
        collection do
          get 'satispay_callback' => :satispay_callback
        end
      end

      hel_resources :invoices, controller: 'invoice/rest' do
      end

      hel_resources :member_services, controller: 'member_service/rest' do
      end

      hel_resources :clubs, controller: 'club/rest' do
      end

      hel_resources :bar_menu_entries, controller: 'bar_menu_entry/rest' do
      end

      hel_resources :bar_transactions, controller: 'bar_transaction/rest' do
      end

      hel_resources :token_transactions, controller: 'token_transaction/rest' do
      end

      hel_resources :gates, controller: 'gate/rest' do
      end
    end
  end
end
