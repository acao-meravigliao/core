#
# Copyright (C) 2013-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notification_objs,
             class_name: '::Ygg::Ml::Msg::Object',
             as: :object

    has_many :notifications,
             class_name: '::Ygg::Ml::Msg',
             through: :notification_objs,
             source: :msg
  end
end

end
end
