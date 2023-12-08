#
# Copyright (C) 2012-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'vihai_password_rails'

module Ygg
module Hel

class HelperController < Ygg::Hel::BaseController

  def generate_password
    case params[:mode]
    when 'phonemic'
      render(json: { password: Password.phonemic(length: params[:len] || 8) })
    when 'xkcd', nil
      pass = Password.xkcd(
        words: params[:words] || 3,
        dict: VihaiPasswordRails.dict(params[:lang] || 'it')
      )
    end

    render(json: { password: pass })
  end
end

end
end
