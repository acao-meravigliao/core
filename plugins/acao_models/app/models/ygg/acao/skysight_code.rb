#
# Copyright (C) 2023-2023, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class SkysightCode < Ygg::PublicModel
  self.table_name = 'acao.skysight_codes'
  self.inheritance_column = false

  belongs_to :person,
             class_name: 'Ygg::Core::Person',
             optional: true

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  def self.assign_and_send!(person:)
    ss_code = self.lock.order(:created_at).first
    ss_code.assigned_to = person
    ss_code.assigned_at = Time.now
    ss_code.save!

    Ygg::Ml::Msg.notify(destinations: person, template: 'SKYSIGHT_COUPON', template_context: {
      first_name: person.first_name,
      skysight_code: ss_code.code,
    }, objects: ss_code)
  end
end

end
end
