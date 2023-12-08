#
# Copyright (C) 2013-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Hel

module ModelHasAcl
  extend ActiveSupport::Concern

  def default_acl_prefilter
#    if aaa_context && aaa_context.authenticated?
#      acl_model = "#{ar_model.name}::AclEntry".constantize
#      subquery = acl_model.where(acl_model.arel_table[:obj_id].eq(ar_model.arel_table[:id]), person_id: aaa_context.auth_person.id)
#      ar_model.where(subquery.arel.exists)
#    else
#      []
#    end
  end

  module ClassMethods
    def model_has_acl
#      build_member_roles(:model_has_acl) do |obj|
#        aaa_context &&
#        aaa_context.authenticated? &&
#        obj.acl_entries.for(aaa_context).map { |x| x.role.to_sym } || []
#      end
    end

    def default_acl_only_prefilter
      alias_method :authorization_prefilter, :default_acl_prefilter
    end
  end
end

end
end
