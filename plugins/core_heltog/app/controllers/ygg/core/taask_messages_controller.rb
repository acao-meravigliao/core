
module Ygg
module Core

class TaaskMessagesController < HelTogether::Controller

#  before_action :setup_environment

#  class MessageTypeNotSupported < StandardError; end
#
#  rescue_from MessageTypeNotSupported, :with => lambda { |e|
#    logger.error e
#    head :not_found
#   }

  def message
    ActiveRecord::Base.transaction do |xact|
      req = Ygg::Core::Taask.lock(true).find_by(id: headers[:correlation_id])

      if !req
        if headers[:type] == 'CREATED' && payload[:request_data]

          params = payload[:request_data]
          params[:scheduler] ||= 'external'

          # To support legacy tasks
          uuid = params.delete(:uuid)
          params[:id] = uuid

          if params[:notifies]
            begin
              params[:notifies] = params[:notifies].map { |x|
                obj = x[:obj_type].constantize.find(x[:obj_id])
                Ygg::Core::Taask::Notify.new(obj: obj)
              }
            rescue ActiveRecord::RecordNotFound, NameError => e
              params.delete(:notifies)
            end
          end

          req = Ygg::Core::Taask.new(params)
          req.save!
        else
          return_from_action true
          return
        end
      end

      if payload
        req.append_log!(payload[:log]) if payload[:log]
        req.update_percent!(payload[:percent]) if payload[:percent]
        req.update_result_data!(payload[:result_data].to_h) if payload[:result_data]
      end

      begin
        case headers[:type]
        when 'NO_OPERATION'
          req.append_log!("======== NO OPERATION ========\n")
          req.permanent_failure!
        when 'STARTED'
          req.started!
        when 'PROGRESS'
          # Do nothing
        when 'COMPLETED'
          req.completed!
        when 'FAILED'
          if payload[:temporary]
            if payload[:wait_event]
              req.wait_for_event!(payload[:wait_event])
            else
              req.temporary_failure!(retry_after: payload[:retry_after] || 5.minutes)
            end
          else
            req.permanent_failure!
          end

          if payload[:exception]
            ex = payload[:exception]
            req.append_log!("#{ex[:title]} #{ex[:descr]}\n#{ex[:backtrace] ? ex[:backtrace].join("\n") : ''}")
          end
        end
      rescue Taask::InvalidTransition => e
        req.append_log!(
          "=======================\n" +
          "#{e}\n" +
          "#{caller.join("\n")}"
        )
        req.change_status!('INCONSISTENT')
      end

      req.save!
    end

    return_from_action true
  end

  def wakeup
    # payload is ignored FIXME

    Ygg::Core::Taask.queue_run!(quick: true)

    return_from_action true
  end

  def crash
    raise "BOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOM!"
  end

end

end
end
