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

class HashedPassword < Credential

  DEFAULT_CYPHER = '6'
  SALT_LEN = 8

  def confidence
    return :medium
  end

  def password=(val)
    val = Password.new(val) if !val.is_a?(Password)

    self.data = val.crypt_with_random_salt(type: DEFAULT_CYPHER, salt_len: SALT_LEN)
  end

  def match_by_password(password)
    password = Password.new(password) if password.is_a?(String)

    return password.crypt_match(self.data)
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
