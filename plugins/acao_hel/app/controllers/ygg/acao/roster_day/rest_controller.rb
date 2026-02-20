#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class RosterDay::RestController < Ygg::Hel::RestController
  ar_controller_for Ygg::Acao::RosterDay

  load_role_defs!

  member_action :daily_form

  view :_default_ do
    attribute :roster_entries do
      attribute :person do
        show!
        empty!
        attribute(:id) { show! }
        attribute(:first_name) { show! }
        attribute(:last_name) { show! }
      end
    end
  end

  def ar_retrieve_resource(id: params[:id])
    if id == 'today'
      m = ar_model.find_by(date: Time.now)
      super(id: m ? m.id : 0)
    else
      super(id: id)
    end
  end

  def ar_apply_filter(rel, filter)
    if filter && filter[:year]
      year = Time.new(filter.delete(:year))
      rel = rel.where(date: (year.beginning_of_year..year.end_of_year))
    end

    rel = super(rel, filter)

    rel
  end

  def daily_form
    ar_retrieve_resource
    ar_authorize_member_action

    respond_to do |format|
      format.pdf do
        render body: ar_resource.daily_form_pdf, content_type: 'application/pdf'
      end
    end
  end

end

end
end
