#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Taask::RestController < Ygg::Hel::RestController

  ar_controller_for Taask

  load_role_defs!

  skip_before_action :ensure_authenticated_and_authorized!, only: [ :cron ]

  collection_action :tree
  collection_action :queue_run
  collection_action :queue_cleanup
  collection_action :queue_purge

  member_action :subtree
  member_action :remove
  member_action :retry
  member_action :cancel
  member_action :continue
  member_action :wait_for_user_done

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:created_at) { show! }
    attribute(:status) { show! }
    attribute(:expected_completion) do
      virtual(:date) { expected_completion }
    end

#    attribute(:service_label) do
#      virtual(:string) { service_label }
#    end
  end

  view :edit do
    self.with_perms = true

  end

  view :tree do
    empty!
    self.with_perms = false
    attribute(:id) { show! }
    attribute(:created_at) { show! }
    attribute(:description) { show! }
#    attribute(:service_label) do
#      virtual(:string) { service_label }
#    end
    attribute(:agent) { show! }
    attribute(:status) { show! }
    attribute(:awaited_event) { show! }
    attribute(:percent) { show! }
  end

  def tree
    ar_authorize_collection_action

    if params[:node] && params[:node] != 'NaN' && params[:node] != 'root'
      ar_respond_with({ children: tree_recurse(Taask.find(params[:node])) })
    else
      rel = Taask.where(depends_on_id: nil).order('created_at DESC')
      rel = apply_simple_filter_to_relation(rel)
      rel = rel.limit(50)
      ar_respond_with(rel.map { |x| tree_recurse(x) })
    end
  end

  def subtree
    ar_retrieve_resource
    ar_authorize_member_action

    ar_respond_with(ar_resource.dependencies.order(:id).map { |x| tree_recurse(x) })
  end

  def cron
    #ar_authorize_collection_action

    Taask.queue_run!

    render nothing: true
  end

  def queue_run
    ar_authorize_collection_action

    Taask.queue_run!

    ar_respond_with({})
  end

  def queue_cleanup
    ar_authorize_collection_action

    Taask.queue_cleanup!

    ar_respond_with({})
  end

  # Empties the queue regardless of the states. Must only be used in emergency situations.
  def queue_purge
    ar_authorize_collection_action

    Taask.all.each { |x| x.destroy }

    ar_respond_with({})
  end

  def remove
    ar_retrieve_resource
    ar_authorize_member_action

    ar_resource.destroy

    ar_respond_with(ar_resource)
  end

  def retry
    ar_retrieve_resource
    ar_authorize_member_action

    ActiveRecord::Base.transaction do
      ar_resource.retry!
      ar_resource.save!
    end

    Taask.queue_run_async!(quick: true)

    ar_respond_with(ar_resource)
  end

  def cancel
    ar_retrieve_resource
    ar_authorize_member_action

    ActiveRecord::Base.transaction do
      ar_resource.cancel!
      ar_resource.save!
    end

    Taask.queue_run_async!(quick: true)

    ar_respond_with(ar_resource)
  end

  def continue
    ar_retrieve_resource
    ar_authorize_member_action

    ActiveRecord::Base.transaction do
      ar_resource.continue!
      ar_resource.save!
    end

    Taask.queue_run_async!(quick: true)

    ar_respond_with(ar_resource)
  end

  def wait_for_user_done
    ar_retrieve_resource
    ar_authorize_member_action

    ActiveRecord::Base.transaction do
      ar_resource.event!('USER_CONFIRMATION')
      ar_resource.save!
    end

    Taask.queue_run_async!(quick: true)

    ar_respond_with(ar_resource)
  end

  protected

  def tree_recurse(obj)
    deps = obj.dependencies.order(:id)

    if !deps.empty?
      ar_hash(obj, view: :tree, format: :deep).merge!(
        { children: deps.map {  |x| tree_recurse(x) } })
    else
      ar_hash(obj, view: :tree, format: :deep).merge!({ leaf: true })
    end
  end

end

end
end
