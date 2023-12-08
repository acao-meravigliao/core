
module Ygg
module Core

class AgentsMessagesController < HelTogether::Controller

  def message
    ActiveRecord::Base.transaction do |xact|
      if payload[:task_endpoint]
        case headers[:type]
        when 'REGISTER'
          agent = Ygg::Core::Agent.find_or_initialize_by(exchange: payload[:task_endpoint])
          agent.last_register = Time.now
          agent.started_on = payload[:started_on]
          agent.version = payload[:version]
          agent.installed_version = payload[:installed_version]
          agent.hostname = payload[:hostname]
          agent.environment = payload[:environment]
          agent.save!

        when 'DEREGISTER'
          agent = Ygg::Core::Agent.find_or_initialize_by(exchange: payload[:task_endpoint])
          agent.last_register = nil
          agent.save!

        end
      end
    end

    return_from_action true
  end
end

end
end
