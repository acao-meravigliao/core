#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Transaction

  attr_accessor :descr
  attr_accessor :params
  attr_accessor :store
  attr_accessor :id

  class TransactionError < StandardError; end

  def yield_callbacks(method)
    if self.class.callbacks[method] && self.class.callbacks[method].respond_to?(:each)
      self.class.callbacks[method].each do |c|

        c.call self
      end
    end
  end

  public
  ######
  #
  # Ygg::Core::Transaction.new("human readable description") do |transaction|
  #
  #   ## do something or fail transaction
  # end
  #
  def initialize(descr, **args, &blk)
    @descr = descr
    @params = args
    @store = {}
    @id = SecureRandom.uuid
    execute(&blk)if block_given?
  end

  # trn = Ygg::Core::Transaction.new("human readable description")
  #
  # trn.execute { # transaction block }
  #
  def execute(&blk)

    raise TransactionError, "There's already an open transaction for #{self.class.current.descr}" if self.class.current

    self.class.current = self

    yield_callbacks :after_start
    ActiveRecord::Base.transaction do
      yield self
      yield_callbacks :before_commit
    end
    yield_callbacks :after_commit

  ensure
    self.class.current = nil
  end

  #
  # returns the current transaction, if any, or nil
  #
  def self.current
    Thread.current[:_ygg_transaction]
  end

  def self.current=(transaction)
    Thread.current[:_ygg_transaction] = transaction
  end

  #
  # registers a callback
  #
  # Ygg::Core::Transaction.callback :after_commit do
  #  # something to do before being transaction has commited
  # end
  #
  def self.callback(method, &blk)
    callbacks[method] ||=[]
    callbacks[method] << blk if !callbacks.include?(blk)
  end

  def self.after_start(&blk)
    callback(:after_start, &blk)
  end

  def self.before_commit(&blk)
    callback(:before_commit, &blk)
  end

  def self.after_commit(&blk)
    callback(:after_commit, &blk)
  end

  def self.callbacks
    @callbacks ||= {}
  end

end

end
end
