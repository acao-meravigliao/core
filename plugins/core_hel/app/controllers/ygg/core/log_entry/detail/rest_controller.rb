#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class LogEntry::Detail::RestController < Ygg::Hel::RestController
  ar_controller_for LogEntry::Detail

  attribute(:previous, type: :reference) do
    self.model_class = 'Ygg::Core::LogEntry::Detail'
  end
end

end
end
