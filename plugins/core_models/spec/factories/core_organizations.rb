#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

FactoryBot.define do
  factory :organization_test, :class => Ygg::Core::Organization do
    name 'Compuglobal'
    vat_number '12345678901'
    italian_fiscal_code '12345678901'

    # TODO --- completare con le associazioni?
  end

  factory :organization_test_2, :parent => :organization_test do
    name 'Enterprise TM'
    vat_number '0011223344'

    # TODO --- completare con le associazioni?
  end
end
