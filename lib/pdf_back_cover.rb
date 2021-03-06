#!/bin/env ruby
# encoding: utf-8
require "prawn"
require "prawn/measurement_extensions"

def back_cover
    @pdf.font "res/Dosis-Regular.ttf"

    @pdf.fill_color = "80e2ff"
    @pdf.fill_rectangle [0.mm, 287.mm], 200.mm, 287.mm
    @pdf.fill_color = "000000"

    @pdf.image "res/kleeros/duo.png", 
      :position => :center,
      :vposition => :center

    @pdf.bounding_box [10.mm,30.mm], :width => 150.mm, :height => 30.mm do

      @pdf.text "<link href='https://www.kleer.la'>www.kleer.la</link>",
        :inline_format => true, :size => 12
      @pdf.text "<link href='mailto:hola@kleer.la'>hola@kleer.la</link>", 
        :inline_format => true, :size => 12
      @pdf.text "<link href='https://facebook.com/kleer.la'>facebook.com/kleer.la</link>", 
        :inline_format => true, :size => 12
      @pdf.text "<link href='https://twitter.com/kleer_la'>twitter.com/kleer_la</link>",
        :inline_format => true, :size => 12
    end

    @pdf.image "res/Logo_Kleer_GrisBlanco.png", 
      :width => 60.mm, 
      :at => [130.mm,30.mm]
end