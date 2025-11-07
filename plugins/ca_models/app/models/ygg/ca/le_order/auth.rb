#
# Copyright (C) 2018-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca
class LeOrder < Ygg::PublicModel

class Auth < Ygg::BasicModel
  self.table_name = 'ca.le_order_auths'
  self.inheritance_column = false

  belongs_to :order,
             class_name: '::Ygg::Ca::LeOrder'

  has_many :challenges,
           foreign_key: :order_auth_id,
           class_name: 'Ygg::Ca::LeOrder::Auth::Challenge',
           embedded: true,
           autosave: true,
           dependent: :destroy,
           inverse_of: :auth # Rails bug https://github.com/rails/rails/issues/25198

  class NotFound < StandardError ; end

  def sync_from_acme!
    resp = order.p_account.generic_get_request(uri: url)
    body = JSON.parse(resp.body)

    transaction do
      update_from_acme(body)
    end

    save!

  rescue Ygg::Ca::LeAccount::RequestProblem => e
    if e.resp.status_code == 404
      self.status = 'expired'
      save!
      raise NotFound
    else
      raise
    end
  end

  def update_from_acme(body)
    update(
      identifier_type: body['identifier']['type'],
      identifier_value: body['identifier']['value'],
      status: body['status'],
      expires_at: body['expires'],
      wildcard: body['wildcard'],
    )

    if status == 'pending' || status == 'valid' || status == 'invalid'
      body['challenges'].each do |challenge|
        c = challenges.find_by(url: challenge['url'])
        if !c
          klass = case challenge['type']
          when 'dns-01'
            Challenge::Dns01
          else
            Challenge
          end

          c = klass.new(auth: self, type: challenge['type'])
        end

        c.update_from_acme(challenge)
        c.save!
      end
    end
  end
end

end
end
end
