# frozen_string_literal: true
#
# Copyright (C) 2014-2024, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg

module Toolkit
  def self.merge(l:, r:, l_cmp_r:, l_to_r:, r_to_l:, lr_update:)
    r_enum = r.each
    l_enum = l.each

    r = r_enum.next rescue nil
    l = l_enum.next rescue nil

    while r || l
      if !l || (r && l_cmp_r.call(l, r) == 1)
        r_to_l.call(r)

        r = r_enum.next rescue nil
      elsif !r || (l &&  l_cmp_r.call(l, r) == -1)
        l_to_r.call(l)

        l = l_enum.next rescue nil
      else
        lr_update.call(l, r)

        l = l_enum.next rescue nil
        r = r_enum.next rescue nil
      end
    end
  end
end

end
