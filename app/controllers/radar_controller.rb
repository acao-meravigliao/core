class RadarController < ApplicationController

  layout false

  def main
    common_stuff
  end

  def embed
    response.headers.except! 'X-Frame-Options'
    common_stuff
  end

  protected

  def common_stuff
    iu = Rails.application.config.extgui.faye_interface_uri
    @faye_interface_uri = iu.kind_of?(Proc) ? instance_exec(&iu) : iu

    iu = Rails.application.config.extgui.faye_source_uri
    @faye_source_uri = iu.kind_of?(Proc) ? instance_exec(&iu) : iu
  end

end
