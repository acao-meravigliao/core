#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

Rails.application.routes.draw do
  namespace :ygg do
    match 'session/check', to: 'hel/session#check', via: [ :get, :post ]
    post 'session/check_or_create', to: 'hel/session#check_or_create'

    post 'session/create', to: 'hel/session#create'
    post 'session/would_authenticate_by_fqda_and_password', to: 'hel/session#would_authenticate_by_fqda_and_password'
    post 'session/authenticate_by_fqda_and_password', to: 'hel/session#authenticate_by_fqda_and_password'
    post 'session/authenticate_by_keyfob', to: 'hel/session#authenticate_by_keyfob'
    post 'session/authenticate_by_certificate', to: 'hel/session#authenticate_by_certificate'
    post 'session/proxy_authenticate_by_fqda', to: 'hel/session#proxy_authenticate_by_fqda'
    post 'session/proxy_authenticate_by_fqda_and_password', to: 'hel/session#proxy_authenticate_by_fqda_and_password'
    post 'session/proxy_authenticate_by_certificate', to: 'hel/session#proxy_authenticate_by_certificate'
    post 'session/refresh', to: 'hel/session#refresh'
    post 'session/renew', to: 'hel/session#renew'
    post 'session/logout', to: 'hel/session#logout'

    get  'session/api-login', to: 'hel/session#api_login'

    get 'search', to: 'hel/search#search'

    get 'hel/helper/generate_password', to: 'hel/helper#generate_password'

    post 'test/email_notifications', to: 'hel/test#email_notifications'

    get 'test/exception', to: 'hel/test#exception'
  end

end
