#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module Loggable
  extend ActiveSupport::Concern

  included do
    has_many :log_entry_details,
             :class_name => '::Ygg::Core::LogEntry::Detail',
             :as => :obj

    has_many :log_entries,
             :class_name => '::Ygg::Core::LogEntry',
             :through => :log_entry_details

    #model_class = self

    #cls = Class.new do
    #  include ActiveRest::Controller

    #  ar_controller_for model_class
    #  self.ar_authorization_required = false
    #  self.ar_prefix = 'Log'
    #end
    #const_set 'LogController', cls
  end

  def log!(transaction_id: nil, description:, person: nil, extra_info: nil, http_session_id: nil, operation: nil)
    log_entry = Ygg::Core::LogEntry.create(
      transaction_id: transaction_id,
      description: description,
      person: person,
      extra_info: extra_info,
      http_session_id: http_session_id,
    )

    log_detail!(log_entry: log_entry, operation: operation)
  end

  def log_detail!(log_entry:, operation:)
    ctrl = (self.class.name + '::LogController').constantize

    Ygg::Core::LogEntry::Detail.create(
      log_entry: log_entry,
      operation: operation ? operation.to_s.upcase : nil,
      obj: self,
      obj_snapshot: ctrl.new.ar_hash(self, format: :deep),
      obj_id: id,
    )
  end

  def log_version(log_entry_detail_id)
    YAML::load(log_entry_details.find(log_entry_detail_id).obj_snapshot)
  end

  def log_diff(old_log_entry_detail_id, new_log_entry_detail_id = nil)
    old_version = log_version(old_log_entry_detail_id)

    new_version = new_log_entry_detail_id ? log_version(new_log_entry_detail_id) : ar_hash(:logcollector, format: :deep)

    diff = {}
    (old_version.keys | new_version.keys).each do |key|
      if old_version[key] != new_version[key]
        diff[key] = { :old => old_version[key], :new => new_version[key] }
      end
    end

    diff
  end
end

end
end
