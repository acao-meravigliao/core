#
# Copyright (C) 2013-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'deep_open_struct'

module Ygg
module Ml

class Template < Ygg::PublicModel
  self.table_name = 'ml.templates'
  self.inheritance_column = false

  belongs_to :language,
             class_name: 'Ygg::I18n::Language',
             optional: true

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  validates :subject, presence: true
  validates :body, presence: true

  def process(context)

    context.deep_transform_keys { |key| key.to_sym rescue key }

    context = DeepOpenStruct.new(context)

    result = {
      subject: ERB.new(subject, trim_mode: '-').result(context.instance_eval { binding }),
      body: ERB.new(body, trim_mode: '-').result(context.instance_eval { binding }),
      email_headers: {},
    }

    if additional_headers
      h = ERB.new(additional_headers, trim_mode: '-').result(context.instance_eval { binding })
      result[:email_headers] = Hash[h.split('\n').map { |x| x.split(':', 2) }]
    end

    result
  end

  def summary
    symbol || subject
  end
end

end
end
