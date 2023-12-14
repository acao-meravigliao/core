#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core
class Person
class Credential

class ObfuscatedPassword < Credential

  validates :fqda, uniqueness: true

  def confidence
    return :medium
  end

  def match_by_password(password)
    return self.password == password
  end

  def password=(val)
    val = Password.new(val) if !val.is_a?(Password)

    self.data = val.symm_encrypt(master_secret: 'spippolo')
  end

  def password
    return nil if !self.data

    return Password.symm_decrypt(self.data, master_secret: 'spippolo')
  end

  def label
    descr || '***'
  end

  def summary
    descr || '***'
  end
end

end
end
end
end
