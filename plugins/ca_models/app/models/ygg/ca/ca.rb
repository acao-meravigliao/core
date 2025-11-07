#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca

class Ca < Ygg::PublicModel
  self.table_name = 'ca.cas'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  include Ygg::Core::Notifiable

  belongs_to :key_pair,
             class_name: '::Ygg::Ca::KeyPair',
             optional: true

  belongs_to :certificate,
             class_name: '::Ygg::Ca::Certificate'

  def summary
    "#{name} - #{descr}"
  end
end

end
end
