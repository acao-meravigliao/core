#
# Copyright (C) 2012-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

Rails.application.routes.draw do

  namespace :ygg do
    namespace :ca do
      hel_resources :key_pairs, controller: 'key_pair/rest' do
      end

      hel_resources :key_stores, controller: 'key_store/rest' do
      end

      hel_resources :certificates, controller: 'certificate/rest' do
      end

      hel_resources :cas, controller: 'ca/rest' do
      end

      hel_resources :le_accounts, controller: 'le_account/rest' do
      end

      hel_resources :le_slots, controller: 'le_slot/rest' do
      end

      hel_resources :le_orders, controller: 'le_order/rest' do
        member do
          post :sync_from_remote
        end

        resources :challenges, controller: 'le_order/rest' do
          get :info, action: 'challenge_info'
          post :start_local_tasks, action: 'challenge_start_local_tasks'
          post :respond, action: 'challenge_respond'
        end
      end
    end
  end

end
