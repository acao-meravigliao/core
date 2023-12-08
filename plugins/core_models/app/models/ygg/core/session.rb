#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'securerandom'

module Ygg
module Core

class Session < Ygg::PublicModel

  self.table_name = 'core.sessions'
  self.inheritance_column = :sti_type

  self.porn_migration += [
    [ :must_have_column, { name: 'id', type: :uuid, null: false, default_function: 'gen_random_uuid()' } ],
    [ :must_have_column, { name: 'sti_type', type: :string, limit: 255, null: false } ],
    [ :must_have_column, { name: 'auth_credential_id', type: :integer } ],
    [ :must_have_column, { name: 'auth_person_id', type: :integer } ],
    [ :must_have_column, { name: 'auth_method', type: :string, limit: 32 } ],
    [ :must_have_column, { name: 'auth_confidence', type: :string, limit: 16 } ],
    [ :must_have_column, { name: 'close_reason', type: :string, limit: 32 } ],
    [ :must_have_column, { name: 'close_time', type: :datetime } ],
    [ :must_have_column, { name: 'status', type: :string, limit: 32 } ],
    [ :must_have_column, { name: 'language_id', type: :integer } ],
#    [ :must_have_column, { name: 'sev_realm_id', type: :string } ],  ### MOVE TO SEVIO
  ]

  belongs_to :auth_credential,
             class_name: 'Ygg::Core::Person::Credential',
             optional: true

  belongs_to :auth_person,
             class_name: 'Ygg::Core::Person',
             optional: true

  if defined? Ygg::I18n
    belongs_to :language,
               class_name: 'Ygg::I18n::Language',
               optional: true
  end

  after_initialize do
    if !new_record? && active? && expires && Time.now > expires
      close!(:expired)
      save!
    end
  end

  def authenticated!(token)
    raise "authenticated! called on an already authenticated session" if status == :authenticated
    raise ArgumentError, 'Person not set' if !token.person

    self.auth_credential = token.credential
    self.auth_person = token.person
    self.auth_method = token.method
    self.auth_confidence = token.confidence
    self.status = :authenticated

    Rails.application.config.core.session_after_authenticated_hooks.each { |x| x.call(self) }

    save!
  end

  def set_language(lang)
    lang = Ygg::I18n::Language.find_by(iso_639_1: lang) unless lang.is_a?(Ygg::I18n::Language)

    raise 'No language found' if !lang

    self.language = lang

    auth_person.preferred_language = lang
    auth_person.save!
  end

  def close!(reason)
    raise "close! called on an already closed session" if !active?

    self.status = :closed
    self.close_reason = reason
    self.close_time = Time.now
    self.save!
  end

  def authenticated?
    status == :authenticated
  end

  def active?
    status == :new || status == :authenticated
  end

  def has_global_roles?(roles)
    auth_person && auth_person.has_global_roles?(roles)
  end

  def global_roles
    auth_person ? auth_person.global_roles : Set.new
  end

  # Workaround for missing enum symbolization
  # fix after fixing enum-column
  def status
    read_attribute(:status).to_sym
  end

  def data
    data = {}

    Rails.application.config.core.session_data_handlers.each { |x| x.call(self, data) }

    data
  end

#
#  def summary
#    id
#  end
end

end
end
