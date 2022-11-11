#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class RosterDay < Ygg::PublicModel
class DailyPdfForm < Prawn::Document
  require 'nokogiri'
  require 'am/http/client'

  def initialize(day:, **args)
    @day = day
    super(**args)
  end

  def draw
    font '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'

    pad(10) do
      text "Linea di #{::I18n.l(@day.date, locale: 'it', format: '%A, %-d %B %Y')}", align: :center, size: 16
    end

    stroke_horizontal_line bounds.left, bounds.right

    move_down 10

    bounding_box([0, cursor], width: bounds.width) do
      curcol = fill_color
      fill_color 'f0f0f0'

      float do
        fill_rectangle([0, cursor], bounds.width, 20)
      end
      fill_color curcol

      pad(5) do
        text 'Componenti', align: :center
      end

      indent(5) do
        pad(5) do
          @day.roster_entries.each do |entry|
            ##### #{entry.chief ? ', Capolinea' : ', Aiuto'}
            text "<font size=\"14\">#{entry.person.name}</font>, #{entry.person.acao_code}", inline_format: true
          end
        end
      end

      stroke_bounds
    end

    move_down 10

    font_size 8

    pos = cursor

    bounding_box([0,pos], width: (bounds.width/2 - 5), height: 200) do
      curcol = fill_color
      fill_color 'f0f0f0'

      float do
        fill_rectangle([0, cursor], bounds.width, 20)
      end
      fill_color curcol

      pad(5) do
        text 'Alianti', align: :center
      end

      indent(5) do
        pad(5) do
          column_box([0,cursor], columns: 2, width: bounds.width, height: bounds.height - 25) do
            Ygg::Acao::Aircraft.where(club_owner: Ygg::Acao::Club.find_by!(symbol: 'ACAO'), is_towplane: false).
                                order(registration: :asc).each do |aircraft|

              text "<font size=\"14\">#{aircraft.available ? '✔' : '✗'}</font>" +
                   aircraft.registration +
                   ' - ' +
                   aircraft.aircraft_type.name +
                   (aircraft.arc_valid_to && aircraft.arc_valid_to < @day.date ? ' ARC SCADUTO' : ' ') +
                   (aircraft.insurance_valid_to && aircraft.insurance_valid_to < @day.date ? ' ASSICURAZIONE SCADUTA' : ' '),
                   inline_format: true
            end
          end
        end
      end

      stroke_bounds
    end

    bounding_box([bounds.width/2 + 5,pos], width: (bounds.width/2) - 5, height: 200) do
      curcol = fill_color
      fill_color 'f0f0f0'

      float do
        fill_rectangle([0, cursor], bounds.width, 20)
      end
      fill_color curcol

      pad(5) do
        text 'Traini', align: :center
      end

      indent(5) do
        pad(5) do
          column_box([0,cursor], columns: 2, width: bounds.width, height: bounds.height - 25) do
            Ygg::Acao::Aircraft.where(club_owner: Ygg::Acao::Club.find_by!(symbol: 'ACAO'), is_towplane: true).
                                order(registration: :asc).each do |aircraft|
              text "<font size=\"14\">#{aircraft.available ? '✔' : '✗'}</font>" +
                   aircraft.registration +
                   ' - ' +
                   aircraft.aircraft_type.name +
                   (aircraft.arc_valid_to && aircraft.arc_valid_to < @day.date ? ' ARC SCADUTO' : ' ') +
                   (aircraft.insurance_valid_to && aircraft.insurance_valid_to < @day.date ? ' ASSICURAZIONE SCADUTA' : ' '),
                   inline_format: true
            end
          end
        end
      end

      stroke_bounds
    end

    font_size 7

    meteo = AM::HTTP::Client.new.get('https://www.astrogeo.va.it/meteo_ipo.php')
    if meteo.status_code == 200
      begin
        meteo_text = Nokogiri::HTML(meteo.body).xpath('//html/body').text
        meteo_text.gsub!(/DOPODOMANI, .*/, '').gsub!(/\n\n\n+/, "\n\n")
      rescue StandardError
      else
        move_down 10

        bounding_box([0,cursor], width: bounds.width, height: cursor) do
          curcol = fill_color
          fill_color 'f0f0f0'

          float do
            fill_rectangle([0, cursor], bounds.width, 20)
          end
          fill_color curcol

          pad(5) do
            text 'Meteo Centro Geofisico Prealpino', align: :center
          end

          indent(5) do
            text meteo_text
          end

          stroke_bounds
        end
      end
    end
  end
end
end

end
end
