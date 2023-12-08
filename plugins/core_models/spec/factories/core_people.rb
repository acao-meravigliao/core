#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

FactoryBot.define do
  factory :person_test, :class => Ygg::Core::Person do
    first_name 'Homer'
    last_name 'Simpson'
    gender 'M'
    birth_date '2000-01-02'
    id_document_type 'Driving License'
    id_document_number '123456'
    vat_number nil
    italian_fiscal_code nil
  end
end
