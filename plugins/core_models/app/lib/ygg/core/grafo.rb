#
# Copyright (C) 2024-2024, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'grafo_store/query'

module Ygg
module Core

module Grafo
  class QueryState
    attr_accessor :rel
    attr_accessor :objs
    attr_accessor :dig_rels
  end

  def self.select(query)
    query = GrafoStore::Query.new(query) unless query.is_a?(GrafoStore::Query)

    state = QueryState.new
    state.rel = query.root.cls.all
    state.objs = Set.new
    state.dig_rels = []

    select_collect_includes(query.root, state)

#    node = query.root


    dig_rels = []

#    rel.each do |obj|
#      objs << obj
#
#      dig_rels.each do |dig_rel|
#        ass = obj.association(dig_rel[:rel])
#        if ass.collection?
#          objs += obj.send(dig_rel[:rel]).to_a
#        else
#          ass_obj = objs.send(dig_rel[:rel])
#          objs << ass_obj if ass_obj
#        end
#      end
#    end

    state
  end

  def self.select_collect_includes(node, state)
    if node.id
      state.rel = state.rel.where(id: node.id)
    elsif node.filter
      state.rel = state.rel.where(node.filter)
    end

    node.dig.each do |dig_part|
      dig_rel = node.cls.gs_rel_map.find { |x| x[:from] == dig_part.from && x[:to] == dig_part.to }
      if dig_rel
#        dig_rels << dig_rel
        state.rel = state.rel.includes(dig_rel[:rel])

        if dig_part.dig
          select_collect_includes(dig_part, state)
        end

puts "INCLUDE #{dig_rel[:rel]}"
      end
    end
  end

end

end
end
