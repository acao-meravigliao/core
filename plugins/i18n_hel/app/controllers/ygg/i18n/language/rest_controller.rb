#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module I18n

class Language::RestController < Ygg::Hel::RestController
  ar_controller_for Language

  skip_before_action :ensure_authenticated_and_authorized!, only: [ :pack ]

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:iso_639_1) { show! }
    attribute(:iso_639_3) { show! }
    attribute(:descr) { show! }
  end

#  view :edit do
#  end

  def ar_retrieve_resource
    if /^[a-z][a-z]$/.match(params[:id])
      @ar_resource = ar_model.find_by!(iso_639_1: params[:id])
    else
      super
    end
  end

  def pack
    ar_retrieve_resource

    res = Hash[ar_resource.translations.includes(:phrase).map { |x| [ x.phrase.phrase, x.value ] }]

    ar_respond_with(res)
  end
end

end
end
