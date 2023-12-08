#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module RoleDefsLoader
  extend ActiveSupport::Concern

  module ClassMethods
    def load_role_defs!(interface: :rest)
#      ar_model.include Ygg::Core::HasMetaClass if !ar_model.respond_to?(:has_meta_class)
#      ar_model.has_meta_class if !ar_model.respond_to?(:meta_class) || ar_model.meta_class.nil?

      return if !ar_model.meta_class

      ar_model.meta_class.members_role_defs.where(interface: interface).each do |role_def|

        attrs = Hash[role_def.attrs.map { |attr_name,attr_def|
          [ attr_name.to_sym,
            ActiveRest::Controller::RoleDef::Attr.new(
              attr_name.to_sym,
              readable: attr_def['readable'],
              writable: attr_def['writable'],
              from: [ attr_name.to_sym ],
            )
          ]
        }]

        member_role(role_def.name,
          allow_all_actions: role_def.allow_all_actions,
          allowed_actions: role_def.actions.map(&:to_sym),
          all_readable: role_def.all_readable,
          all_writable: role_def.all_writable,
          attrs: attrs,
        )
      end

      ar_model.meta_class.collection_role_defs.where(interface: interface).each do |role_def|

        attrs = Hash[role_def.attrs.map { |attr_name,attr_def|
          [ attr_name.to_sym,
            ActiveRest::Controller::RoleDef::Attr.new(
              attr_name.to_sym,
              readable: attr_def['readable'],
              writable: attr_def['writable'],
              from: [ attr_name.to_sym ],
            )
          ]
        }]

        collection_role(role_def.name,
          allow_all_actions: role_def.allow_all_actions,
          allowed_actions: role_def.actions.map(&:to_sym),
          all_readable: role_def.all_readable,
          all_writable: role_def.all_writable,
          attrs: attrs,
        )
      end
    end
  end
end

end
end
