#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class OrgapeopleController < Ygg::Hel::RestController

  view :grid do
#    for_class 'Ygg::Core::Organization' do
#      empty!
#      self.with_type = true
#      attribute(:id) { show! }
#      attribute(:name) { show! }
#      attribute(:handle) { show! }
#      attribute(:vat_number) { show! }
#    end
#
#    for_class 'Ygg::Core::Person' do
#      empty!
#      self.with_type = true
#      attribute(:id) { show! }
#      attribute(:first_name) { show! }
#      attribute(:last_name) { show! }
#      attribute(:italian_fiscal_code) { show! }
#      attribute(:handle) { show! }
#    end
  end

  def index
    rel1 = Ygg::Core::Organization.limit(25)
    rel1 = my_apply_search_to_relation(rel1, Ygg::Core::Organization, [ 'name' ])

    rel2 = Ygg::Core::Person.limit(25)
    rel2 = my_apply_search_to_relation(rel2, Ygg::Core::Person, [ 'first_name', 'last_name' ])

    out_rel = rel1 + rel2

    self.ar_resources = out_rel
    self.ar_resources_count = out_rel.count

    ctr_o = Ygg::Core::Organization::RestController.new(aaa_context: aaa_context)
    ctr_p = Ygg::Core::Person::RestController.new(aaa_context: aaa_context)

    ar_respond_with(out_rel.map { |x|
      case x
      when Ygg::Core::Person
        {
         ygg_core_person: ctr_p.ar_render_one(x, format: :deep, view: :grid),
         ygg_core_person_id: x.id,
         ygg_core_person_type: x.class.name,
        }
      when Ygg::Core::Organization
        {
         ygg_core_organization: ctr_o.ar_render_one(x, format: :deep, view: :grid),
         ygg_core_organization_id: x.id,
         ygg_core_organization_type: x.class.name,
        }
      end
    })
  end

  protected

  def my_apply_search_to_relation(rel, model, search_in)
    return rel if !params[:search]

    expr = nil

    search_in.each do |x|
      (attr, rel) = model.nested_attribute(x, rel)
      e = attr.matches('%' + params[:search] + '%')
      expr = expr ? expr.or(e) : e
    end

    rel = rel.where(expr)
    rel
  end

  def ar_retrieve_resources
    rel1 = Ygg::Core::Organization.limit(25)
    rel1 = my_apply_search_to_relation(rel1, Ygg::Core::Organization, [ 'name' ])

    rel2 = Ygg::Core::Person.limit(25)
    rel2 = my_apply_search_to_relation(rel2, Ygg::Core::Person, [ 'first_name', 'last_name' ])

    out_rel = rel1 + rel2

    self.ar_resources = out_rel
    self.ar_resources_count = out_rel.count

    ar_resources
  end
end

end
end
