#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class Address < Ygg::PublicModel
  self.table_name = 'ml.addresses'

  validates :addr, presence: true
  validates :addr_type, presence: true

  has_many :list_members,
           class_name: '::Ygg::Ml::List::Member',
           dependent: :destroy

  has_many :lists,
           class_name: '::Ygg::Ml::List',
           through: :list_members

  has_many :messages,
           class_name: '::Ygg::Ml::Msg::Rcpt',
           dependent: :destroy

  has_many :validation_tokens,
           class_name: '::Ygg::Ml::Address::ValidationToken',
           dependent: :destroy

  gs_rel_map << { from: :address, to: :validation_token, to_cls: '::Ygg::Ml::Address::ValidationToken', to_key: 'address_id' }

  def bounce_received!
    self.failed_deliveries += 1
    self.reliability_score = self.reliability_score * 0.7

    if reliability_score < 0.3
      self.reliable = false
    end
  end

  def start_validation!(person:)
    transaction do
      vt = validation_tokens.create!(expires_at: Time.now + 1.hour)

      tpl = Ygg::Ml::Template.find_by(symbol: 'ML_EMAIL_VALIDATION', language: person.preferred_language) ||
            Ygg::Ml::Template.find_by(symbol: 'ML_EMAIL_VALIDATION')

      raise "Template missing" if !tpl

      Ygg::Ml::Msg::Email.notify_raw(
        sender: Rails.application.config.ml.default_sender,
        rcpt_name: person.name,
        rcpt: addr,
        tpl: tpl,
        template_context: {
          code: vt.code,
          first_name: person.first_name,
          expires_at: vt.expires_at,
        },
        person: person,
        objects: [ self ],
        msg_attrs: {},
        flush: false,
      )
    end

    Ygg::Ml::Msg.queue_flush!
  end
end

end
end
