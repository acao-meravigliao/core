#
# Copyright (C) 2016-2024, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Person::VosController < RailsVos::Controller
  vos_controller_for Ygg::Acao::KeyFob

#  include Ygg::Core::ReplicasController


#  def authorization_prefilter
#    ar_model.where(person_id: aaa_context.auth_person.id)
#  end
#
#  build_member_roles(:blahblah) do |obj|
#    aaa_context.auth_person.id == obj.person_id ? [ :owner ] : []
#  end
end

end
end
