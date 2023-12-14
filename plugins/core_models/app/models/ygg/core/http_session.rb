#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'securerandom'

module Ygg
module Core

class HttpSession < Ygg::Core::Session

  self.porn_migration += [
    [ :must_have_column, { name: 'http_x_forwarded_for', type: :text } ],
    [ :must_have_column, { name: 'http_via', type: :text } ],
    [ :must_have_column, { name: 'http_server_addr', type: :string, limit: 42 } ],
    [ :must_have_column, { name: 'http_server_port', type: :integer } ],
    [ :must_have_column, { name: 'http_server_name', type: :string, limit: 64 } ],
    [ :must_have_column, { name: 'http_referer', type: :text } ],
    [ :must_have_column, { name: 'http_user_agent', type: :text } ],
    [ :must_have_column, { name: 'http_request_uri', type: :text } ],
    [ :must_have_column, { name: 'http_remote_addr', type: :string, limit: 42 } ],
    [ :must_have_column, { name: 'http_remote_port', type: :integer } ],
  ]

end

end
end
