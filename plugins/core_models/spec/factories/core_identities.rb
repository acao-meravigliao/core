#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

FactoryBot.define do
# prototype
  factory :identity_generic, :class => Ygg::Core::Identity do
    association :person, :factory => :person_test
    qualified 'no-one@nowherefast.com'
  end

# used

  factory :identity_weak, :parent => :identity_generic do
    qualified 'homer.simpson@springfield.com'
    secret 'peanuts'
    confidence :weak
  end

  factory :identity_medium, :parent => :identity_weak do
    qualified 'ilovemarge@simpson.com'
    secret 'bart'
    confidence :medium
  end

  factory :identity_strong, :parent => :identity_weak do
    qualified 'big.boss@compuglobal.com'
    secret 'my_big_boss_secret'
    confidence :strong
  end
end
