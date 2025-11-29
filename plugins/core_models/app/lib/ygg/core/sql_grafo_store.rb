#
# Copyright (C) 2024-2024, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'grafo_store/basic'
require 'grafo_store/query'

module Ygg
module Core

class SqlGrafoStore < GrafoStore::Basic
  def sel_destroyed(sel)
    super

    sel.objs.each do |obj_id,obj|
      if @sels.none? { |x| x.objs[obj_id] }
        @objs.delete(obj_id)
        @rels.reject! { |x| x.match?(a: obj) }
      end
    end
  end

  def select(query, **params)
    if !params || !params[:sql_dont_fetch]
      begin
        sel = sql_select(query)
      rescue SelectFailure => e
        puts "EEEEEEEEEEEEEEEEEEEEEEEEEEEEE #{e}"
        puts "EEEEEEEEEEEEEEEEEEEEEEEEEEEEE #{e.backtrace}"
        raise ::GrafoStore::Selection::SelectError.new
      rescue StandardError => e
        puts "EEEEEEEEEEEEEEEEEEEEEEEEEEEEE #{e}"
        puts "EEEEEEEEEEEEEEEEEEEEEEEEEEEEE #{e.backtrace}"
        raise ::GrafoStore::Selection::SelectError.new
      end
    end

    res = super(query, **params)

    res
  end

  class SelectFailure < Ygg::Exception ; end
  class FilterSyntaxError < SelectFailure ; end
  class MissingRelDef < SelectFailure ; end

  def sql_select(query)

    query = ::GrafoStore::Query.new(sel: nil, query: query) unless query.is_a?(GrafoStore::Query)

    query.root.each do |node|
      select_collect_sub(node, nil, nil, nil)
    end
  end

  def select_collect_sub(node, parent_node, parent_cls, parent_objs)
    to_gs_cls = nil
    to_ar_cls = nil
    reldef = nil

    if parent_node
      reldef = parent_cls.ar_class.gs_rel_map.find { |x| x[:from] == node.from && x[:to] == node.to }
      if !reldef
        raise MissingRelDef.new(title: "Missing rel #{node.from} => #{node.to}")
      end

      to_ar_cls = Object.const_get(reldef[:to_cls], false)
      to_gs_cls = to_ar_cls.gs_class
    else
      to_gs_cls = node.cls
      to_ar_cls = to_gs_cls.ar_class
    end

    rel = to_ar_cls.all

    if parent_objs
      if reldef[:to_key]
        rel = rel.where(reldef[:to_key] => parent_objs.map(&:id))
      else
        rel = rel.where(id: parent_objs.map(&reldef[:from_key].to_sym))
      end
    end

    if node.id
      rel = rel.where(id: node.id)
    elsif node.filter
      node.filter.each do |k,v|
        if v.is_a?(Hash)
          v.symbolize_keys!

          if v.has_key?(:between)
            rel = rel.where(k => v[:between][0]..v[:between][1])
          elsif v.has_key?(:gt)
            rel = rel.where(k => v[:gt]...)
          elsif v.has_key?(:gte)
            rel = rel.where(k => v[:gte]..)
          elsif v.has_key?(:lt)
            rel = rel.where(k => ...v[:lt])
          elsif v.has_key?(:lte)
            rel = rel.where(k => ..v[:lte])
          else
            raise FilterSyntaxError
          end
        else
          rel = rel.where(k => v)
        end
      end
    end

    if node.order
      rel = rel.order(node.order).offset(node.start).limit(node.limit)
    end

    node_ar_objs = rel.to_a
    node_gs_objs = Set.new

    node_ar_objs.each do |ar_obj|
      gs_obj = ar_obj.class.gs_class.new(**ar_obj.attributes)

      node_gs_objs << gs_obj
      @objs[ar_obj.id] = gs_obj.freeze
    end

    if parent_objs
      parent_objs.each do |from_obj|
        node_ar_objs.each do |to_ar_obj|
          if (reldef[:to_key] && to_ar_obj.send(reldef[:to_key]) == from_obj.id) ||
             (reldef[:from_key] && from_obj.send(reldef[:from_key]) == to_ar_obj.id)
            @rels << ::GrafoStore::Rel.new(a: from_obj.id, a_as: node.from, b: to_ar_obj.id, b_as: node.to)
          end
        end
      end
    end

    if node.dig
      node.dig.each do |dig|
        select_collect_sub(dig, node, to_gs_cls, node_gs_objs)
      end
    end
  end
end

end
end
