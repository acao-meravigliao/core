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
      match 'bounces' => 'bounces#bounce', via: [ :message ]
    end
  end

end
