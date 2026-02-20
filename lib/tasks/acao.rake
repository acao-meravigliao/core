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
      TimeoutActor.new(tout: 400).do do
        Ygg::Acao::Member.sync_wordpress!
      end
    end
  end

  namespace :debts do
    task(:chores => :environment) do
      TimeoutActor.new(tout: 100).do do
        Ygg::Acao::Debt.run_chores!
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

  task(update_meteo: :environment) do
    TimeoutActor.new(tout: 100).do do
      Ygg::Acao::MeteoEntry.update!
    end
  end

  task(:'aircrafts' => :environment) do
    desc 'Sync aircrafts'

    TimeoutActor.new(tout: 300).do do
      Ygg::Acao::FlarmnetEntry.sync!
    end

    TimeoutActor.new(tout: 300).do do
      Ygg::Acao::OgnDdbEntry.sync!
    end

    TimeoutActor.new(tout: 100).do do
      Ygg::Acao::Aircraft.transaction do
        Ygg::Acao::Aircraft.sync_from_maindb!
      end
    end
  end

  task(:'bar_transactions' => :environment) do
    desc 'Sync bar transactions'

    TimeoutActor.new(tout: 100).do do
      Ygg::Acao::BarTransaction.sync_from_maindb!(from_time: Time.now - 1.month)
    end
  end

  task(:'token_transactions' => :environment) do
    desc 'Sync token transactions'

    TimeoutActor.new(tout: 100).do do
      Ygg::Acao::TokenTransaction.sync_from_maindb!(from_time: Time.now - 1.month)
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
