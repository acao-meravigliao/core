#
# Copyright (C) 2008-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class ReplicaNotify < Ygg::PublicModel
  self.table_name = 'core.replica_notifies'

  belongs_to :obj,
             polymorphic: true

  belongs_to :notify_obj,
             polymorphic: true

  def self.check_for(obj:)
    where(obj: obj).each do |notify|

      transaction do
        if Ygg::Core::Replica.where(obj: obj).all? { |x| x.version_done == x.version_needed || x.version_done >= notify.version_needed }
          # It may have been destroyed
          if notify.notify_obj
            notify.notify_obj.run_hook(:replicas_completed, notify)
          end

          notify.destroy!
        end
      end
    end

  end
end

end
end
