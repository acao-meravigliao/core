#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

Rails.application.routes.draw do

  namespace :ygg do
    namespace :ml do
      hel_resources :addresses, controller: 'address/rest' do
        collection do
          post :validate
        end
      end

      hel_resources :lists, controller: 'list/rest' do
      end

      hel_resources :senders, controller: 'sender/rest' do
      end

      hel_resources :msgs, controller: 'msg/rest' do
      end

      hel_resources :templates, controller: 'template/rest' do
      end

      hel_resources :bounces, controller: 'bounce/rest' do
      end
    end
  end

end
