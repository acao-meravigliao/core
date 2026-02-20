# frozen_string_literal: true
#
# Copyright (C) 2017-2026, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Day < Ygg::PublicModel
  self.table_name = 'acao.days'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  def daily_form_pdf
   pdf = DailyPdfForm.new(day: self, page_size: 'A4', page_layout: :portrait)
   pdf.draw
   str = pdf.render

   str
  end

  def print_daily_form
    pdfstr = daily_form_pdf

    IO.popen([ '/usr/bin/lpr', "-P#{Rails.application.config.acao.printer}" ], File::WRONLY, encoding: Encoding::ASCII_8BIT) do |io|
      io.write(pdfstr)
    end
  end
end

end
end
