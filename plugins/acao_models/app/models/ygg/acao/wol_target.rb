# frozen_string_literal: true
#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

#require 'am/ssh/client'

module Ygg
module Acao

class WolTarget < Ygg::PublicModel
  self.table_name = 'acao.wol_targets'

  def self.gs_fetch(gs:, node:)

    rel = all

    if node.id
      rel = rel.where(id: node.id)
    elsif node.filter
      rel = rel.where(node.filter)
    end

    gs.transaction do
      rel.each do |model|
        if model
          if !gs.objs[node.id]
            gs.obj_add(model)
          end
        end
      end
    end

  end

  def wake!
    system('ssh',
      '-i', Rails.application.config.acao.wol_key_path,
      "#{Rails.application.config.acao.wol_username}@#{Rails.application.config.acao.wol_host}",
      "/tool wol interface=#{interface} mac=#{mac}")

    # key_manager = AM::SSH::KeyManager.new
    # key_manager.add_keyfile(priv_filename: "/opt/lino-wol")
    #
    # ssh = AM::SSH::Client.new(
    #   host: 'rutterone.acao.it',
    #   auth: [
    #     { method: 'publickey', username: 'lino-wol', key_manager: key_manager },
    #   ],
    #   reconnect: false,
    #   idle_timeout: 20,
    #   keepalive: 5,
    #   debug: 3,
    # )
    #
    # out = ssh.exec_whole("/tool/wol interface=vlanl0 mac=#{mac}")
    # puts out.stdout
    #
    # ssh.exit

  end
end

end
end
