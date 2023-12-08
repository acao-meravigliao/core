#
# Copyright (C) 2008-2018, Daniele Orlandi
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module Versioned
  extend ActiveSupport::Concern

  included do
    class_attribute :versioning_sensitive_attributes
    class_attribute :versioning_insensitive_attributes
    self.versioning_insensitive_attributes = [
      :created_at,
      :updated_at,
      :version,
    ]

    self.porn_migration << [ :must_have_column, { name: 'version', type: :integer, null: false, default: 0 } ]

    before_save do
      if versioning_version_changed?
        self.version += 1
      end
    end

    class << self
      prepend PrependedClassMethods
    end
  end

  module PrependedClassMethods
    def inherited(child)
      super(child)

      child.versioning_sensitive_attributes = versioning_sensitive_attributes.try(:deep_dup)
      child.versioning_insensitive_attributes = versioning_insensitive_attributes.try(:deep_dup)
    end
  end

  def versioning_version_changed?
    versioning_sensitive_attributes ?
      (versioning_sensitive_attributes.map(&:to_s) & deep_changes.keys).any? :
      (deep_changes.keys - versioning_insensitive_attributes.map(&:to_s)).any?
  end

end

end
end
