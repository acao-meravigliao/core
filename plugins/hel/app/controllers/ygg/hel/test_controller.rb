#
# Copyright (C) 2015-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Hel

class TestController < AuthenticatedController
  layout false

  def email_notification
    Ygg::Ml::Msg.notify(
      destinations: aaa_context.auth_person,
      template: 'TEST',
      object: nil,
      context: { :test => 123 })
  end

  def exception
    raise "This is a test unhandled exception generated in backend"
  end
end

end
end
