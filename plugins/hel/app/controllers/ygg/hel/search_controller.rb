#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Hel

class SearchController < AuthenticatedController
  include RailsActiveRest::Controller::Responder

  def search
    sh = PgSearch.multisearch(params[:q]).map do |x|
     {
      klass: x.searchable_type,
      id: x.searchable_id,
      class_human_name: x.searchable.class.model_name.human,
      abstract: x.searchable.summary,
     }
    end

    ar_respond_with(sh)
  end
end

end
end
