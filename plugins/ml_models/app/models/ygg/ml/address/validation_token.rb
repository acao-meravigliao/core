#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml
class Address < Ygg::PublicModel

class ValidationToken < Ygg::PublicModel
  self.table_name = 'ml.address_validation_tokens'

  belongs_to :address,
             class_name: '::Ygg::Ml::Address'

  gs_rel_map << { from: :validation_token, to: :address, to_cls: '::Ygg::Ml::Address', from_key: 'address_id' }

  after_initialize do
    if new_record?
      self.code = Password.random(length: 6, symbols: '0123456789')
    end
  end

  def validated!
    transaction do
      self.used_at = Time.now
      save!

      address.update!(
        validated: true,
        reliable: true,
        reliability_score: 100,
      )
    end
  end
end

end
end
end
