#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#


module Ygg
module Streaming
class Channel < Ygg::PublicModel

class Variant < Ygg::BasicModel
  self.table_name = 'str_channel_variants'

  belongs_to :channel,
             class_name: 'Ygg::Streaming::Channel'

  define_default_provisionable_controller(self)
end

end
end
end
