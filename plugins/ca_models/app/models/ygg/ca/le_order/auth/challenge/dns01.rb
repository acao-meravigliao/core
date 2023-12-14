#
# Copyright (C) 2018-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ca
class LeOrder < Ygg::PublicModel
class Auth < Ygg::BasicModel
class Challenge < Ygg::BasicModel

class Dns01 < Challenge

  include Ygg::Core::Taskable

  task_completed do |task|
    # Manual confirmation task

    begin
      transaction do
        respond!
      end
    rescue NotFound, Ygg::Ca::LeAccount::RequestProblem, InvalidState
    end
  end

  task_failed do |task|
    self.my_status = 'internal_failure'
    save!
  end

  task_canceled do |task|
    self.my_status = 'internal_failure'
    save!
  end

  include Ygg::Core::ReplicaNotifiable
  replicas_completed do |notification|

    self.my_status = 'responding'
    save!

    begin
      respond!
    rescue NotFound, Ygg::Ca::LeAccount::RequestProblem, InvalidState
    end
  end

  def record_name
    '_acme-challenge.' + auth.identifier_value
  end

  def record_data
    Base64.urlsafe_encode64(OpenSSL::Digest::SHA256.digest(authorization_key(token))).sub(/[\s=]*\z/, '')
  end

  def authorization_key(token)
    "#{token}.#{auth.order.p_account.jwk.thumbprint}"
  end

  def start_local_tasks!
    task = nil

    logger.info "LE starting DNS-01 for #{auth.identifier_value}"

    transaction do
      self.started_at = Time.now
      self.my_status = 'dns_change_pending'
      save!


      zone = Ygg::Dns::Zone.find_nearest(record_name)
      if zone
        relative_name = zone.relative_name(record_name)

        zone.records.where(name: relative_name, rr_class: 'IN', rr_type: 'TXT').destroy_all
        zone.records.load_target # Workaround for ActiveRecord which does not cache the association unless explicitly told to. #deep_changes gets broken
        zone.records << Ygg::Dns::Zone::Record.new(
          name: relative_name,
          ttl: 1.seconds,
          rr_class: 'IN',
          rr_type: 'TXT',
          data: record_data,
          owners: [ Ygg::Dns::Zone::Record::Owner.new(obj: self) ]
        )

        zone.update_soa_serial!
        zone.save!

        zone.replicas_req_notify(notify_obj: self)
        zone.replicas_force!
      else
        task = Ygg::Core::Taask.new(
          operation: 'WAIT_FOR_EVENT',
          expected_completion: nil,
          description: "Manually create DNS record '#{record_name}. 1 IN TXT #{record_data}'",
          request_data: 'USER_CONFIRMATION',
        )

        task.notifies << Ygg::Core::Taask::Notify.new(obj: self)
        task.save!
      end

      save!
    end

    task
  end
end

end
end
end
end
end
