namespace :acao do
  desc 'Sync stuff'

  task(:syncall => :environment) do
    models = [
      'Ygg::Acao::MainDb::Socio',
      'Ygg::Acao::MainDb::SociDatiLicenza',
      'Ygg::Acao::MainDb::SociDatiVisita',
      'Ygg::Acao::MainDb::SocioIscritto',
      'Ygg::Acao::MainDb::Mezzo',
      'Ygg::Acao::MainDb::Volo',
      'Ygg::Acao::MainDb::LogBar2',
    ]

    models.each do |model_name|
      model = model_name.constantize

      if model.has_been_updated?
        case model_name
        when 'Ygg::Acao::MainDb::Socio', 'Ygg::Acao::MainDb::SociDatiLicenza', 'Ygg::Acao::MainDb::SociDatiVisita', 'Ygg::Acao::MainDb::SocioIscritto',
             'Ygg::Acao::MainDb::LogBar2'

          puts "Updating Ygg::Acao::Pilot"

          Ygg::Acao::Pilot.sync_from_maindb!

          Ygg::Acao::MainDb::Socio.update_last_update!
          Ygg::Acao::MainDb::SociDatiLicenza.update_last_update!
          Ygg::Acao::MainDb::SociDatiVisita.update_last_update!
          Ygg::Acao::MainDb::SocioIscritto.update_last_update!
          Ygg::Acao::MainDb::LogBar2.update_last_update!

        when 'Ygg::Acao::MainDb::Mezzo'
          puts "Updating Ygg::Acao::Aircraft"
          Ygg::Acao::Aircraft.sync_from_maindb!

        when 'Ygg::Acao::MainDb::Volo'
          puts "Updating Ygg::Acao::Flight"

          start_id = Ygg::Acao::Flight.order(takeoff_time: :asc).where('takeoff_time > ?', Time.now - 30.days).first.source_id

          Ygg::Acao::Flight.sync_from_maindb!(start: start_id, limit: 1000)

        else
        end

        model.update_last_update!
      end
    end
  end

  namespace :people do
    task(:sync => :environment) do
      Ygg::Acao::Pilot.sync_from_maindb!
    end

    task(:chores => :environment) do
      Ygg::Acao::Pilot.run_chores!
    end
  end

  namespace :payments do
    task(:chores => :environment) do
      Ygg::Acao::Payment.run_chores!
    end
  end

  namespace :roster do
    task(:chores => :environment) do
      Ygg::Acao::RosterDay.find_by(date: Time.now).check_and_mark_chief!

      # Print roster sheet
    end
  end

  task(:'aircrafts' => :environment) do
    desc 'Sync aircrafts'

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
    Ygg::Acao::Pilot.sync_soci_ml!
  end
end
