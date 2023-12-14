#
# Yggdra
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
      match 'task_messages' => 'taask_messages#message', :via => [ :message ]
      match 'task_wakeup' => 'taask_messages#wakeup', :via => [ :message ]
      match 'replica_process_requests' => 'replica_messages#process_all', :via => [ :message ]
      match 'crash' => 'taask_messages#crash', :via => [ :message ]

      match 'agents_messages' => 'agents_messages#message', :via => [ :message ]
    end
  end
end
