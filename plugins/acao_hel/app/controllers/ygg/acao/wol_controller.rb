#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'am/ssh/client'

module Ygg
module Acao

class WolController < Ygg::Hel::BaseController
  layout false

  def wake
#    ensure_authenticated!
#
#    raise "Föra di ball" unless aaa_context.has_global_roles?(:superuser)

    mac = json_request[:mac]

    raise "Wrong MAC format" if !(mac =~ /[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}/)

    system('ssh', '-i', '/opt/lino-wol', 'lino-wol@rutterone.acao.it', "/tool wol interface=vlan10-office mac=#{json_request[:mac]}")

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

    respond_to do |format|
      format.json { render json: {} }
    end
  end
end

end
end
