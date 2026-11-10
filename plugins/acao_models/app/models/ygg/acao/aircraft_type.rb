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

  def self.import_from_ac_types(types)
    types.each do |type|
      cls = type[0].strip
      name = type[1].strip

      act = Ygg::Acao::AircraftType.connection.execute(Ygg::Acao::AircraftType.
               sanitize_sql(['SELECT * FROM acao.aircraft_types, similarity(name, ?) AS simil WHERE simil > 0.8 ORDER BY simil DESC LIMIT 1', name ])).first

      if !act
        puts "#{name}: CREATED #{cls}"

        self.create!(
          name: name,
          aircraft_class: cls,
          ogn_ddb_name: name,
          manufacturer: 'NNNNNN',
          seats: 999,
          motor: 999,
        )
      elsif !act['aircraft_class']
        puts "#{name}: FIX CLASS"

        Ygg::Acao::AircraftType.find(act['id']).update!(aircraft_class: cls)
      else
        puts "#{name}: FOUND"
      end

    end
  end
end

end
end
