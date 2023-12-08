#
# Copyright (C) 2012-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Agent < Ygg::PublicModel
  self.table_name = 'core.agents'

  self.porn_migration += [
    [ :must_have_column, { name: 'id', type: :uuid, null: false, default_function: 'gen_random_uuid()' } ],
    [ :must_have_column, { name: 'exchange', type: :string, null: false } ],
    [ :must_have_column, { name: 'descr', type: :string } ],
    [ :must_have_column, { name: 'symbol', type: :string, limit: 32 } ],
    [ :must_have_column, {:name=>"should_be_running", :type=>:boolean, :default=>false, :null=>false}],
    [ :must_have_column, {:name=>"last_register", :type=>:datetime, :default=>nil, :null=>true}],
    [ :must_have_column, {:name=>"version", :type=>:string, :default=>nil, :limit=>10, :null=>true}],
    [ :must_have_column, {:name=>"installed_version", :type=>:string, :default=>nil, :limit=>10, :null=>true}],
    [ :must_have_column, {:name=>"started_on", :type=>:datetime, :default=>nil, :null=>true}],
    [ :must_have_column, {:name=>"hostname", :type=>:string, :default=>nil, :limit=>255, :null=>true}],
    [ :must_have_column, {:name=>"environment", :type=>:string, :default=>nil, :limit=>64, :null=>true}],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)
  define_default_provisioning_controller(self)

  ## No attribute is sensitive for authorization
  #idxc_cached
  #self.idxc_sensitive_attributes = []

  validates :exchange, presence: true

  def rpc(operation:, data: nil, timeout: 5.seconds)
    RailsAmqp.interface.task(
      exchange: exchange,
      operation: operation,
      data: data,
      timeout: timeout,
    )
  end

  def send_exit
    rpc(operation: :exit)
  end
end

end
end

