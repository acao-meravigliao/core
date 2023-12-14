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

class Challenge < Ygg::BasicModel
  self.table_name = 'ca.le_order_auth_challenges'
  self.inheritance_column = :sti_type

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: true}],
    [ :must_have_column, {name: "order_auth_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "status", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "my_status", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "type", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "url", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "token", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "created_at", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "started_at", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "error_type", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "error_status", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "error_detail", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "sti_type", type: :string, default: nil, null: true}],

    [ :must_have_index, {columns: ["order_auth_id"], unique: false}],

    [ :must_have_fk, {to_table: "ca_le_order_auths", column: "order_auth_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  belongs_to :auth,
             foreign_key: :order_auth_id,
             class_name: '::Ygg::Ca::LeOrder::Auth'

  class NotFound < StandardError ; end

  def sync_from_acme!
    resp = auth.order.p_account.generic_get_request(uri: url)
    body = JSON.parse(resp.body)

    update_from_acme(body)

    save!
  rescue Ygg::Ca::LeAccount::RequestProblem => e
    if e.resp.status_code == 404
      self.status = 'expired'
      save!
      raise NotFound
    elsif e.resp.status_code >= 500
      raise
    end
  end

  def update_from_acme(body)
    update!(
      status: body['status'],
      url: body['url'],
      token: body['token'],
      error_type: body['error'] ? body['error']['type'] : nil,
      error_status: body['error'] ? body['error']['status'] : nil,
      error_detail: body['error'] ? body['error']['detail'] : nil,
    )
  end

  def started?
    !started_at.nil?
  end

  class InvalidState < StandardError ; end

  def respond!
    raise InvalidState, "Wrong status '#{status}'" if status != 'pending'

    self.my_status = 'responding'
    save!

    response = auth.order.p_account.generic_request(
      uri: url,
      payload: { },
    )

    update_from_acme(JSON.parse(response.body))

    self.my_status = 'responded'
    save!

  rescue Ygg::Ca::LeAccount::RequestProblem => e
    if e.resp.status_code == 404
      self.status = 'expired'
      save!
      raise NotFound
    elsif e.resp.status_code >= 400 && e.resp.status_code < 500
      self.my_status = 'respond_failure'
      self.error_status = e.resp.status_code.to_s
      self.error_detail = e.resp.body
      save!
    end

    raise
  end
end

end
end
end
end
