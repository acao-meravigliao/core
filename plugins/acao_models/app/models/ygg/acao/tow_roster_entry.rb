# frozen_string_literal: true
#
# Copyright (C) 2017-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class TowRosterEntry < Ygg::PublicModel
  self.table_name = 'acao.tow_roster_entries'

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  belongs_to :day,
             class_name: 'Ygg::Acao::TowRosterDay'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  after_initialize do
    if new_record?
      self.selected_at = Time.now
    end
  end

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

end

end
end
