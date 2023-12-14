#
# Copyright (C) 2008-2018, Daniele Orlandi
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

# Principle of operation:
#
# - A user may want to receive a index of the models he has access to
# - Determining the accessibility of a model may be a computationally intensive process
# - the table from which the models are obtained may be big
# - a superset of the models list may be obtained via SQL, not much bigger than the final index
#
# We can thus compute the superset then, for each model, compute its visibility and cache the result
#
# Can we compute the visibility just via SQL?
#   Ygg::Sevio::Device     .where(realm: aaa_context.auth_person.sev_realms)
#   Ygg::Sevio::Access     .where(person_id: aaa_context.auth_person.id)
#   Ygg::Sevio::Realm      .joins(:operators).where(sev_realm_operators: { person_id: aaa_context.auth_person.id })
#
# When a model is created it must be noted in the caches that the prefilter must be run again
#
# We run the prefilter and insert in the cache a record for each record prefiltered, even the ones that will not be visible
# - The cache entry will have a boolean column:
#   - null: state not known, should be evaluated
#   - true: accessible
#   - false: not accessible
#

module Ygg
module Core

module HasIndexCache
  extend ActiveSupport::Concern

  included do
    class << self
      prepend PrependedClassMethods
    end

  end

  module PrependedClassMethods
    def idxc_cached
      has_many :idxc_entries,
               class_name: 'Ygg::Core::IndexCacheEntry',
               as: :obj

      class_attribute :idxc_sensitive_attributes
      class_attribute :idxc_insensitive_attributes
      self.idxc_insensitive_attributes = [
        :created_at,
        :updated_at,
        :version,
      ]

      after_create do
        Ygg::Core::IndexCacheStatus.where(obj_type: self.class.name).each do |cache_status|
          cache_status.has_dirty = true
          cache_status.save!
        end
      end

      before_update do
        if idxc_changed?
          statuses = Ygg::Core::IndexCacheStatus.where(obj_type: self.class.name)
          statuses.update_all(has_dirty: true)
          person_ids = statuses.select('person_id').map(&:person_id)

          # XXX this could be optimized
          statuses.each do |cache_status|
            # Make dirty every entry in the cache or add a new dirty entry if missing
            cache_entry = Ygg::Core::IndexCacheEntry.find_or_initialize_by(obj: self, person_id: cache_status.person_id)
            cache_entry.accessible = nil
            cache_entry.save!
          end
        end
      end

      after_destroy do
        Ygg::Core::IndexCacheStatus.where(obj_type: self.class.name).destroy_all
        Ygg::Core::IndexCacheEntry.where(obj: self).destroy_all
      end

      class_eval do
        define_method(:inherited) do |child|
          super(child)

          child.idxc_sensitive_attributes = idxc_sensitive_attributes.try(:deep_dup)
          child.idxc_insensitive_attributes = idxc_insensitive_attributes.try(:deep_dup)
        end
      end
    end
  end

  def idxc_changed?
    idxc_sensitive_attributes ?
      (idxc_sensitive_attributes.map(&:to_s) & deep_changes.keys).any? :
      (deep_changes.keys - idxc_insensitive_attributes.map(&:to_s)).any?
  end

  module ClassMethods
    def idxc_check(aaa_context:, rel:, ar_member_action_allowed:)
      transaction do

        # Here something like a 'INSERT OR REPLACE' would be nicer
        ActiveRecord::Base.connection.execute("LOCK #{Ygg::Core::IndexCacheStatus.table_name} IN ACCESS EXCLUSIVE MODE")

        status = Ygg::Core::IndexCacheStatus.find_or_initialize_by(obj_type: self.name, person: aaa_context.auth_person)

        if status.new_record?
          # There shouldn't be cache entries already, but delete them all just in case...
          Ygg::Core::IndexCacheEntry.where(obj_type: name, person: aaa_context.auth_person).delete_all
          Ygg::Core::IndexCacheEntry.where(obj_type: name, person: aaa_context.auth_person).delete_all
        end

        if status.new_record? || status.has_dirty
          connection.execute('INSERT INTO idxc_entries (obj_type, obj_id, person_id) ' +
                             rel.select(connection.quote(name), :id, connection.quote(aaa_context.auth_person.id)).to_sql +
                             ' ON CONFLICT DO NOTHING')

          Ygg::Core::IndexCacheEntry.where(obj_type: name, person: aaa_context.auth_person, accessible: nil).each do |cache_entry|
            dirty_obj = cache_entry.obj

            cache_entry.accessible = ar_member_action_allowed.call(dirty_obj, [ :show, :index ])
            cache_entry.save!
          end
        end

        if status.changed?
          status.has_dirty = false
          status.updated_at = Time.now
          status.save!
        end

          #prefiltered_rel = rel
          #
          #prefiltered_rel.each do |obj|
          #  if ar_member_action_allowed.call(obj, [ :show, :index ])
          #    obj.idxc_entries.create!(person: aaa_context.auth_person, dirty: false)
          #  end
          #end
        #else
          #if status.has_new_from_id
          #  # New objects have been created in this model for an existing cache, we should fetch them and check if thei are readable

          #  id_field = arel_table[:id]
          #  new_rel = rel.where(id_field.gteq(status.has_new_from_id))

          #  new_rel.each do |new_obj|
          #    if ar_member_action_allowed.call(new_obj, [ :show, :index ])
          #      new_obj.idxc_entries.create!(person: aaa_context.auth_person)
          #    end
          #  end

          #  status.has_new_from_id = nil
          #end

          #if status.has_dirty
          #  Ygg::Core::IndexCacheEntry.where(obj_type: name, person: aaa_context.auth_person, dirty: true).each do |cache_entry|
          #  end

          #end
        #end

      end
    end

    def idxc_clear(person_id: nil)
      rel = Ygg::Core::IndexCacheStatus.where(obj_type: self.name)
      rel = rel.where(person_id: person_id) if person_id
      rel.destroy_all

      rel = Ygg::Core::IndexCacheEntry.where(obj_type: self.name)
      rel = rel.where(person_id: person_id) if person_id
      rel.destroy_all
    end

    def idxc_relation(person_id:)
      joins(:idxc_entries).where(idxc_entries: { person_id: person_id, accessible: true })
    end
  end
end

end
end
