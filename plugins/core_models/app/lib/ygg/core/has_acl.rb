#
# Copyright (C) 2013-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module HasAcl
  extend ActiveSupport::Concern

  module EnabledMethods
    def acl_replace_auto(grants:, owner:)
#      transaction do
#        acl_entries.where(owner: owner).destroy_all
#
#        acl_entries << grants.map { |k,v| (self.class.name + '::AclEntry').constantize.new(person_id: k, role: v, owner: owner) }
#      end
    end
  end

  module ClassMethods
    def acl_table_name
      table_name + '_acl'
    end

    def has_acl
#      include EnabledMethods
#
#      acl_table_name = self.acl_table_name
#
##      if !ActiveRecord::Base.connection.data_source_exists?(acl_table_name) && !Rails.application.config.core.disable_acl_creation
##        ActiveRecord::Schema.define do
##          create_table acl_table_name do |t|
##            t.references :obj, :null => false
##            t.references :person
##            t.references :group
##            t.string :role, :limit => 64, :null => false
##            t.references :owner, polymorphic: true
##          end
##
##          add_index acl_table_name, :obj_id    rescue nil
##          add_index acl_table_name, :person_id rescue nil
##          add_index acl_table_name, :group_id  rescue nil
##          add_index acl_table_name, :role      rescue nil
##          #add_index acl_table_name, [ :obj_id, :person_id, :group_id, :roley ], :unique => true, :name => "#{acl_table_name}_oigc"
##        end
##      end
#
#      base_class_name = self.name
#
#      klass = Class.new(Ygg::Core::AclEntryBase) do
#        belongs_to :obj,
#                   :class_name => base_class_name
#
#        self.table_name = acl_table_name
#
#        #validates :capability, uniqueness: { scope: [ :obj_id, :person_id, :group_id, :capability ] }
#
#        define_default_log_controller(self)
#      end
#      klass.table_name = acl_table_name
#
#      const_set('AclEntry', klass)
#
#      has_many :acl_entries,
#               class_name: self.name + '::AclEntry',
#               foreign_key: 'obj_id',
#               dependent: :destroy,
#               embedded: true,
#               autosave: true
#    rescue ActiveRecord::NoDatabaseError
    end

  end
end

#class AclEntryBase < Ygg::BasicModel
#  self.abstract_class = true
#
#  belongs_to :group,
#             class_name: 'Ygg::Core::Group',
#             optional: true
#
#  belongs_to :person,
#             class_name: 'Ygg::Core::Person',
#             optional: true
#
#  belongs_to :owner,
#             polymorphic: true,
#             optional: true
#
#  def self.for(aaa_context)
#    where(person_id: aaa_context.auth_person.id).or(where(group_id: aaa_context.auth_person.groups.map(&:id)))
#  end
#end

end
end
