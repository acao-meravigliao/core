#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

Rails.application.routes.draw do

  namespace :ygg do
    namespace :core do
#      get 'person/credential/obfuscated_passwords/schema' => 'person/credential/obfuscated_password/rest#get_schema'
#      get 'person/credential/hashed_passwords/schema' => 'person/credential/hashed_password/rest#get_schema'
#      get 'person/credential/x509_certificates/schema' => 'person/credential/x509_certificate/rest#get_schema'

      hel_resources :klasses, controller: 'klass/rest' do
        collection do
          get :my_roles_for_collections
          get :my_roles_for_all_members
        end

        member do
          get :members_actions
          get :collection_actions
          get :attrs
        end
      end

      hel_resources :organizations, controller: 'organization/rest' do
        collection do
          get :similar_to
        end

        member do
          post :update_acls
          post :invoice_all_pending
          post :force_billing_flush

          get :similar
          post :merge
        end
      end

      hel_resources :people, controller: 'person/rest' do
        collection do
          get :current
          get :similar_to
        end

        member do
          post :update_acls
          post :invoice_all_pending
          post :force_billing_flush
          post :change_password

          get :similar
          post :merge
        end
      end

      resources :orgapeople do
      end

      hel_resources :groups, controller: 'group/rest' do
      end

      hel_resources :log_entries, controller: 'log_entry/rest' do
      end

      hel_resources :sessions, controller: 'session/rest' do
      end

      hel_resources :taasks, controller: 'taask/rest' do
        collection do
          get :tree
          post :queue_run
          post :queue_cleanup
          post :queue_purge
          match :cron, :via => [ :message ]
        end

        member do
          get :subtree
          post :remove
          post :retry
          post :cancel
          post :continue
          post :wait_for_user_done
        end
      end

      hel_resources :replicas, controller: 'replica/rest' do
      end

      hel_resources :global_roles, controller: 'global_role/rest' do
      end

      hel_resources :agents, controller: 'agent/rest' do
      end

    end
  end

end
