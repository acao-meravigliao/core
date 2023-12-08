#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Klass::RestController < Ygg::Hel::RestController

  ar_controller_for Ygg::Core::Klass

  collection_action :my_roles_for_collections
  collection_action :my_roles_for_all_members

  view :edit do
    self.with_perms = true

    attribute :members_role_defs do
      show!
    end

    attribute :collection_role_defs do
      show!
    end
  end

  def my_roles_for_collections
    ctrls = Ygg::Core::Klass.all_classes.map { |x| x.respond_to?(:ar_guess_controller) ? (x.ar_guess_controller rescue nil) : nil }.compact
    ctrls = ctrls.map { |ctr| ctr.new(aaa_context: aaa_context) }.select { |x| x.respond_to?(:ar_collection_roles) }
    res = Hash[ctrls.map { |ctr|
       [ ctr.ar_model.name,
         {
          allowed_actions: ctr.ar_collection_build_allowed_actions_from_roles(ctr.ar_collection_roles),
         }
       ]
     } ]

    ar_respond_with(res)
  end

  def my_roles_for_all_members
    ctrls = Ygg::Core::Klass.all_classes.map { |x| x.respond_to?(:ar_guess_controller) ? (x.ar_guess_controller rescue nil) : nil }.compact
    ctrls = ctrls.map { |ctr| ctr.new(aaa_context: aaa_context) }.select { |x| x.respond_to?(:ar_non_member_specific_roles) }
    res = Hash[ctrls.map { |ctr|
       [ ctr.ar_model.name,
         {
          allowed_actions: ctr.ar_member_build_allowed_actions_from_roles(ctr.ar_non_member_specific_roles),
         }
       ]
     } ]

    ar_respond_with(res)
  end

  def members_actions
    ar_retrieve_resource

    ar_respond_with((ar_resource.name + '::RestController').constantize.ar_member_actions.keys)
  end

  def collection_actions
    ar_retrieve_resource

    ar_respond_with((ar_resource.name + '::RestController').constantize.ar_collection_actions.keys)
  end

  def attrs
    ar_retrieve_resource

    ar_respond_with(Hash[(ar_resource.name + '::RestController').constantize.ar_attrs.map { |k,v| [ k, {
      type: v.type,
      name: v.name,
      name_in_model: v.name_in_model,
      human_name: v.human_name,
      ignored: v.ignored,
      notnull: v.notnull,
      readable: v.readable,
      writable: v.writable,
    } ] }])
  end

end

end
end
