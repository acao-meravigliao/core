#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

Rails.application.routes.draw do

  namespace :ygg do
    namespace :i18n do

      hel_resources :languages, controller: 'language/rest' do
        member do
          get :pack
        end
      end

      hel_resources :phrases, controller: 'phrase/rest' do
      end

    end
  end

end
