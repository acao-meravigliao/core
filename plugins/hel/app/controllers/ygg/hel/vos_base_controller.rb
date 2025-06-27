#
# Copyright (C) 2008-2025, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#
# Hel's BaseController includes common functionalities for all Hel's controller. It does retrieve session information if
# present and provide common methods to check session validity.
#

module Ygg
module Hel

class VosBaseController
  class SessionInvalid < Ygg::Exception ; end
  class SessionInvalid::NotAuthenticated < SessionInvalid ; end
  class SessionInvalid::SessionClosed < SessionInvalid ; end
  class SessionInvalid::SessionStatusInvalid < SessionInvalid ; end
  class AuthorizationError < Ygg::Exception ; end

  attr_reader :vos_server
  attr_reader :ds
  attr_reader :session

  def initialize(vos_server:, ds:, session:)
    @vos_server = vos_server
    @ds = ds
    @session = session
  end

  def ensure_authenticated!

    if !session
      raise SessionNotFoundError
    elsif !session.authenticated?
      case session.status
      when :new
        raise SessionInvalid::NotAuthenticated
      when :closed
        raise SessionInvalid::SessionClosed
      else
        raise SessionInvalid::SessionStatusInvalid
      end
    end

    true
  end

end

end
end
