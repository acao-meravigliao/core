#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class RosterDay::VosController < Ygg::Hel::VosBaseController

  def compute_stats(**)
    ensure_authenticated!
    raise AuthorizationError unless session.has_global_roles?(:superuser)

    time = Time.now

    if time.month >= 10
      prev_year = time.year
      out_year = time.year + 1
    else
      prev_year = time.year - 1
      out_year = time.year
    end

   {
    estimate_needed: Ygg::Acao::Member.all.joins(:memberships).
                       where(memberships: { reference_year: Ygg::Acao::Year.find_by!(year: prev_year) }).
                       map { |x| x.roster_entries_needed(time: Time.new(out_year, 1, 1))[:total] }.sum,
    estimate_members_of_year: prev_year,
    estimate_year: out_year,
   }
  end

end

end
end
