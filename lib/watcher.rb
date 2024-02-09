#! /usr/bin/ruby

loop do
  changed = false
  mezzo_changed = false

  if Ygg::Acao::MainDb::Socio.has_been_updated?
    puts "Socio has been changed"
    changed = true
  end

  if Ygg::Acao::MainDb::SociDatiLicenza.has_been_updated?
    puts "SociDatiLicenza has been changed"
    changed = true
  end

  if Ygg::Acao::MainDb::SociDatiVisita.has_been_updated?
    puts "SociDatiVisita has been changed"
    changed = true
  end

  if Ygg::Acao::MainDb::SocioIscritto.has_been_updated?
    puts "SocioIscritto has been changed"
    changed = true
  end

  if Ygg::Acao::MainDb::Mezzo.has_been_updated?
    puts "Mezzo has been changed"
    changed = true
    mezzo_changed = true
  end

  if Ygg::Acao::MainDb::LogBar2.has_been_updated?
    puts "LogBar2 has been changed"
    changed = true
  end

  if Ygg::Acao::MainDb::CassettaBarLocale.has_been_updated?
    puts "CassettaBarLocale has been changed"
    changed = true
  end

  if Ygg::Acao::MainDb::LogBollini.has_been_updated?
    puts "LogBollini has been changed"
    changed = true
  end

  if changed
    puts "Updating Pilot(s)"

    Ygg::Acao::Pilot.sync_from_maindb!(
       with_logbar: Ygg::Acao::MainDb::LogBar2.has_been_updated? || Ygg::Acao::MainDb::CassettaBarLocale.has_been_updated?,
       with_logbollini: Ygg::Acao::MainDb::LogBollini.has_been_updated?,
       debug: 2)

  #XXX add FAAC
  #XXX add FAAC

    Ygg::Acao::MainDb::Socio.update_last_update!
    Ygg::Acao::MainDb::SociDatiLicenza.update_last_update!
    Ygg::Acao::MainDb::SociDatiVisita.update_last_update!
    Ygg::Acao::MainDb::SocioIscritto.update_last_update!
    Ygg::Acao::MainDb::LogBar2.update_last_update!
    Ygg::Acao::MainDb::CassettaBarLocale.update_last_update!
    Ygg::Acao::MainDb::LogBollini.update_last_update!

    puts "done"
  end

  if Ygg::Acao::MainDb::Mezzo.has_been_updated?
     puts "Updating Ygg::Acao::Aircraft"
     Ygg::Acao::Aircraft.sync_from_maindb!
     Ygg::Acao::MainDb::Mezzo.update_last_update!
     puts "done"
  end

  if Ygg::Acao::MainDb::Volo.has_been_updated?
    puts "Updating Ygg::Acao::Flight"

    ff = Ygg::Acao::Flight.order(takeoff_time: :asc).where('takeoff_time > ?', Time.now - 30.days).first
    start_id = ff ? ff.source_id : 0

    Ygg::Acao::Flight.sync_from_maindb!(start: start_id, debug: 1)

    Ygg::Acao::MainDb::Volo.update_last_update!

    puts "done"
  end

  #Ygg::Acao::Onda::DocTesta.trigger_replacement

  sleep 5
end
