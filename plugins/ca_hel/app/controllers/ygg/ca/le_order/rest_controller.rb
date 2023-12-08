#
# Copyright (C) 2012-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class LeOrder::RestController < Ygg::Hel::RestController
  ar_controller_for Ygg::Ca::LeOrder

  member_action :sync_from_remote
  member_action :challenge_info
  member_action :challenge_start_local_tasks
  member_action :challenge_respond

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:status) { show! }
    attribute(:created_at) { show! }
    attribute(:expires) { show! }
    attribute(:auths) do
      show!
      empty!
      attribute(:status) { show! }
      attribute(:identifier_type) { show! }
      attribute(:identifier_value) { show! }
    end
    attribute(:account) do
      show!
      empty!
      attribute(:symbol) { show! }
    end
  end

  view :edit do
    self.with_perms = true

    attribute(:account) do
      show!
    end

    attribute(:auths) do
      show!
      attribute(:challenges) do
        show!
      end
    end
  end

  def sync_from_remote
    ar_retrieve_resource
    ar_authorize_member_action

    ar_resource.sync_from_acme!

    ar_respond_with({})
  end

  def challenge_info
    ar_retrieve_resource(id: params[:le_order_id])
    ar_authorize_member_action

    challenge = Ygg::Ca::LeOrder::Auth::Challenge.find(params[:challenge_id])

    case challenge.type
    when 'dns-01'
      ar_respond_with({ text:
        'Create a DNS record like this<br />' +
        '<br />' +
        "#{challenge.record_name} 0 IN TXT #{challenge.record_data}<br />" +
        '<br />' +
        'Then select \'Attempt\' on this menu'
      })
    else
      ar_respond_with({ text:
        'This challenge is not yet supported'
      })
    end
  end

  def challenge_start_local_tasks
    ar_retrieve_resource(id: params[:le_order_id])
    ar_authorize_member_action

    challenge = Ygg::Ca::LeOrder::Auth::Challenge.find(params[:challenge_id])
    challenge.start_local_tasks!

    ar_respond_with({ })
  end

  def challenge_respond
    ar_retrieve_resource(id: params[:le_order_id])
    ar_authorize_member_action

    challenge = Ygg::Ca::LeOrder::Auth::Challenge.find(params[:challenge_id])
    challenge.respond!

    ar_respond_with({ })
  end
end

end
end
