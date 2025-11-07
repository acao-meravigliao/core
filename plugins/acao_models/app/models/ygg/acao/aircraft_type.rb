# frozen_string_literal: true
#
# Copyright (C) 2008-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class AircraftType < Ygg::PublicModel
  self.table_name = 'acao.aircraft_types'

  has_many :aircrafts,
           class_name: 'Ygg::Acao::Aircraft'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  validates_presence_of :manufacturer
  validates_presence_of :name
  validates_presence_of :seats
  validates_numericality_of :seats

  validates_presence_of :motor
  validates_numericality_of :motor

  validates_numericality_of :handicap, :allow_nil => true
  validates_numericality_of :handicap_club, :allow_nil => true
end

end
end
