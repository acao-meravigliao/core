#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

FactoryBot.define do
  factory :group_admin, :class => Ygg::Core::Group do
    name 'administrators'
    description 'yada yada, admin description'
  end

  factory :group_tech, :class => Ygg::Core::Group do
    name 'technicians'
    description 'yada yada, tech description'
  end
end
