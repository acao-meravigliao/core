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

  has_many :messages_as_recipient,
           class_name: '::Ygg::Ml::Msg',
           foreign_key: :recipient_id,
           dependent: :nullify

  has_many :validations,
           class_name: '::Ygg::Ml::Address::Validation',
           dependent: :destroy

  gs_rel_map << { from: :ml_address, to: :person_email, to_cls: '::Ygg::Core::Person::Email', to_key: 'ml_address_id' }
  gs_rel_map << { from: :address, to: :validation, to_cls: '::Ygg::Ml::Address::Validation', to_key: 'address_id' }
  gs_rel_map << { from: :recipient, to: :message, to_cls: '::Ygg::Ml::Msg', to_key: 'recipient_id' }

  def delivery_failed!
    self.failed_deliveries += 1
    self.reliability_score = self.reliability_score * 0.7

    if reliability_score < 30
      self.reliable = false
    end

    save!
  end

  def delivery_successful!
    self.reliability_score = [ self.reliability_score * 1.3, 100 ].min

    if reliability_score > 80
      self.reliable = true
    end

    save!
  end

  def start_validation!(person:)
    transaction do
      vt = validations.create!(expires_at: Time.now + 1.hour)

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
