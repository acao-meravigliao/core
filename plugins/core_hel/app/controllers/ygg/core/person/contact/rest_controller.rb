#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Person::Contact::RestController < Ygg::Hel::BasicController
  ar_controller_for Person::Contact

  load_role_defs!

  build_member_roles(:blahblah) do |obj|
    # Inherit roles from its person
    ar_ctr_get(for_model: obj.person).ar_member_roles(obj.person)
  end
end

end
end
