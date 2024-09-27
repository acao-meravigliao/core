require 'actor_model'
class TimeoutActor
  include AM::Actor

  class Ref < AM::ActorRef
    def do
      yield
      exit
    end
  end

  self.actor_ref_class = Ref

  def initialize(tout:, **args)
    @tout = tout

    super(**args)
  end

  def actor_boot
    after(@tout) do
      puts "========================================== TIMEOUT! ============================================="

      Thread.list.each do |th|
        puts "----------------- Thread #{th} -------------------"
        puts th.backtrace
      end

      Process.exit!(255)
    end
  end
end

namespace :acao do
  namespace :people do
    task(:chores => :environment) do
      TimeoutActor.new(tout: 100).do do
        Ygg::Acao::Member.run_chores!
      end
    end

    task(:sync_ml => :environment) do
      TimeoutActor.new(tout: 100).do do
        Ygg::Acao::Member.sync_mailing_lists!
      end
    end

    task(:sync_wp => :environment) do
      TimeoutActor.new(tout: 100).do do
        Ygg::Acao::Member.sync_wordpress!
      end
    end
  end

  namespace :payments do
    task(:chores => :environment) do
      TimeoutActor.new(tout: 100).do do
        Ygg::Acao::Payment.run_chores!
      end
    end
  end

  namespace :invoices do
    task(:chores => :environment) do
      TimeoutActor.new(tout: 100).do do
        Ygg::Acao::Invoice.run_chores!
      end
    end
  end

  namespace :roster do
    task(print_daily_form: :environment) do
      TimeoutActor.new(tout: 100).do do

        today_roster = Ygg::Acao::RosterDay.find_by(date: Time.now)
        if today_roster
          today_roster.check_and_mark_chief!
          today_roster.print_daily_form
        end
      end
    end
  end

  task(:'aircrafts' => :environment) do
    desc 'Sync aircrafts'

    TimeoutActor.new(tout: 100).do do
      Ygg::Acao::Aircraft.sync_from_maindb!
    end
  end

#  task('aircrafts:frequent' => :environment) do
#    Ygg::Acao::Flight.sync_frequent!
#  end
#
#
#  task(:'aircrafts:flarmnet' => :environment) do
#    Ygg::Acao::Aircraft.import_flarmnet_db!
#  end
#
#  task(:'flights' => :environment) do
#  end
end
