# frozen_string_literal: true
#
# Copyright (C) 2017-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#


module Ygg
module Acao

class AccessRemote < Ygg::PublicModel
  self.table_name = 'acao.access_remotes'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

  has_one :member_remote,
           class_name: 'Ygg::Acao::MemberAccessRemote',
           foreign_key: :remote_id

  def self.code_from_faac(code)
    code.to_i(8).to_s(16).rjust(10, '0')
  end

  def code_for_faac(code)
    code ? code.to_i(16).to_s(8).rjust(8, '0') : nil
  end

  def ch1_code_for_faac
    code_for_faac(ch1_code)
  end

  def ch2_code_for_faac
    code_for_faac(ch2_code)
  end

  def ch3_code_for_faac
    code_for_faac(ch3_code)
  end

  def ch4_code_for_faac
    code_for_faac(ch4_code)
  end
end

end
end
