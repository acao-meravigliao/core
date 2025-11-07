# frozen_string_literal: true
#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Year < Ygg::PublicModel
  self.table_name = 'acao.years'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  has_many :memberships,
           foreign_key: :reference_year_id,
           class_name: 'Ygg::Acao::Membership'

  gs_rel_map << { from: :year, to: :membership, to_cls: 'Ygg::Acao::Membership', from_key: 'year_id', }
  gs_rel_map << { from: :membership, to: :member, to_cls: 'Ygg::Acao::Member', to_key: 'member_id', }

  def self.renewal_year
    Ygg::Acao::Year.where('renew_opening_time < ?', Time.now).order(year: :desc).first
  end

  def self.next_renewal_year
    Ygg::Acao::Year.where('renew_announce_time < ?', Time.now).order(year: :desc).first
  end

  def previous
    self.class.find_by(year: year - 1)
  end
end

end
end
