#
# Copyright (C) 2015-2015, Daniele Orlandi
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module DeepDirty
  def deep_changes
    res = {}

    @association_cache.each do |k,v|
      next unless v.options[:embedded]

      case v
      when ActiveRecord::Associations::BelongsToAssociation
        if v.target
          changes = v.target.respond_to?(:deep_changes) ? v.target.deep_changes : v.target.changes
          res[k] = changes unless changes.empty?
        end
      when ActiveRecord::Associations::HasManyAssociation
        hm = v.target.select { |x| x.changed? }.map { |x| [ x.id, x.respond_to?(:deep_changes) ? x.deep_changes : x.changes ] }
        res[k] = Hash[hm] unless hm.empty?
      end
    end

    changes.merge(res)
  end

  def deep_changed?
    changed? ||
    @association_cache.any? do |k,v|
      next unless v.options[:embedded]

      case v
      when ActiveRecord::Associations::BelongsToAssociation
        v.target.respond_to?(:deep_changed?) ? v.target.deep_changed? : (v.target ? v.target.changed? : false)
      when ActiveRecord::Associations::HasManyAssociation
        v.target.any? { |x| x.respond_to?(:deep_changed?) ? x.deep_changed? : x.changed? }
      end
    end
  end
end

end
end
