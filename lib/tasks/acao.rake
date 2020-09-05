require 'actor_model'
class TimeoutActor
  include AM::Actor

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
  desc 'Sync stuff'

  task(:syncall => :environment) do
    TimeoutActor.new(tout: 300)

    if Ygg::Acao::MainDb::Socio.has_been_updated? ||
       Ygg::Acao::MainDb::SociDatiLicenza.has_been_updated? ||
       Ygg::Acao::MainDb::SociDatiVisita.has_been_updated? ||
       Ygg::Acao::MainDb::SocioIscritto.has_been_updated? ||
       Ygg::Acao::MainDb::Mezzo.has_been_updated? ||
       Ygg::Acao::MainDb::LogBar2.has_been_updated? ||
       Ygg::Acao::MainDb::CassettaBarLocale.has_been_updated? ||
       Ygg::Acao::MainDb::LogBollini.has_been_updated?

      #puts "Updating Ygg::Acao::Pilot"

      Ygg::Acao::Pilot.sync_from_maindb!(with_logbar: Ygg::Acao::MainDb::LogBar2.has_been_updated? || Ygg::Acao::MainDb::CassettaBarLocale.has_been_updated?, with_logbollini: Ygg::Acao::MainDb::LogBollini.has_been_updated?)

      Ygg::Acao::MainDb::Socio.update_last_update!
      Ygg::Acao::MainDb::SociDatiLicenza.update_last_update!
      Ygg::Acao::MainDb::SociDatiVisita.update_last_update!
      Ygg::Acao::MainDb::SocioIscritto.update_last_update!
      Ygg::Acao::MainDb::LogBar2.update_last_update!
      Ygg::Acao::MainDb::CassettaBarLocale.update_last_update!
      Ygg::Acao::MainDb::LogBollini.update_last_update!
    end

    if Ygg::Acao::MainDb::Mezzo.has_been_updated?
       #puts "Updating Ygg::Acao::Aircraft"
       Ygg::Acao::Aircraft.sync_from_maindb!
       Ygg::Acao::MainDb::Mezzo.update_last_update!
    end

    if Ygg::Acao::MainDb::Volo.has_been_updated?
      #puts "Updating Ygg::Acao::Flight"

      ff = Ygg::Acao::Flight.order(takeoff_time: :asc).where('takeoff_time > ?', Time.now - 30.days).first
      start_id = ff ? ff.source_id : 0

      Ygg::Acao::Flight.sync_from_maindb!(start: start_id, limit: 1000)

      Ygg::Acao::MainDb::Volo.update_last_update!
    end
  end

  namespace :people do
    task(:sync => :environment) do
      TimeoutActor.new(tout: 100)
      Ygg::Acao::Pilot.sync_from_maindb!
    end

    task(:chores => :environment) do
      TimeoutActor.new(tout: 100)
      Ygg::Acao::Pilot.run_chores!
    end
  end

  namespace :payments do
    task(:chores => :environment) do
      TimeoutActor.new(tout: 100)
      Ygg::Acao::Payment.run_chores!
    end
  end

  namespace :invoices do
    task(:chores => :environment) do
      TimeoutActor.new(tout: 100)
      Ygg::Acao::Invoice.run_chores!
    end
  end

  namespace :roster do
    task(print_daily_form: :environment) do
      TimeoutActor.new(tout: 100)

      today_roster = Ygg::Acao::RosterDay.find_by(date: Time.now)
      if today_roster
        today_roster.check_and_mark_chief!
        today_roster.print_daily_form
      end
    end
  end

  task(:'aircrafts' => :environment) do
    desc 'Sync aircrafts'

    TimeoutActor.new(tout: 100)
    Ygg::Acao::Aircraft.sync_from_maindb!
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

  task(:'ml:soci' => :environment) do
    TimeoutActor.new(tout: 100)
    Ygg::Acao::Pilot.sync_soci_ml!
  end
end
