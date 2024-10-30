#! /usr/bin/ruby

debug = 2

puts "---------------- Watcher Started ----------------" if debug >= 1

ino = File.stat(__FILE__).ino

loop do

  if File.stat(__FILE__).ino != ino
    puts "==================== WATCHER REPLACED, RELOADING ====================="
    exit
  end

  soci_changed = false
  mezzo_changed = false
  volo_changed = false
  onda_changed = false
  logbar_changed = false
  logbol_changed = false

  puts "loop" if debug >= 4

  if Ygg::Acao::MainDb::Socio.has_been_updated?
    puts "Socio has been changed" if debug >= 1
    soci_changed = true
  end

  if Ygg::Acao::MainDb::SociDatiLicenza.has_been_updated?
    puts "SociDatiLicenza has been changed" if debug >= 1
    soci_changed = true
  end

  if Ygg::Acao::MainDb::SociDatiVisita.has_been_updated?
    puts "SociDatiVisita has been changed" if debug >= 1
    soci_changed = true
  end

  if Ygg::Acao::MainDb::SocioIscritto.has_been_updated?
    puts "SocioIscritto has been changed" if debug >= 1
    soci_changed = true
  end

  if Ygg::Acao::MainDb::Tessera.has_been_updated?
    puts "Tessera has been changed" if debug >= 1
    soci_changed = true
  end

  if Ygg::Acao::MainDb::Mezzo.has_been_updated?
    puts "Mezzo has been changed" if debug >= 1
    soci_changed = true
    mezzo_changed = true
  end

  if Ygg::Acao::Onda::DocTesta.has_been_updated?
    puts "DocTesta has been changed" if debug >= 1
    onda_changed = true
  end

  if soci_changed
    puts "Updating Pilot(s)" if debug >= 1

    time0 = Time.new
    Ygg::Acao::Pilot.sync_from_maindb!(debug: debug)
    puts "Pilots update done, took #{Time.new - time0} seconds" if debug >= 1

    time0 = Time.new
    puts "  FAAC update started" if debug >= 1
    Ygg::Acao::Pilot.sync_with_faac!(grace_period: 1.month, debug: 1)
    puts "  FAAC update done, took #{Time.new - time0} seconds" if debug >= 1

    Ygg::Acao::MainDb::Socio.update_last_update!
    Ygg::Acao::MainDb::SociDatiLicenza.update_last_update!
    Ygg::Acao::MainDb::SociDatiVisita.update_last_update!
    Ygg::Acao::MainDb::SocioIscritto.update_last_update!
    Ygg::Acao::MainDb::Tessera.update_last_update!
  end

  if mezzo_changed
     time0 = Time.new
     puts "Updating Ygg::Acao::Aircraft" if debug >= 1
     Ygg::Acao::Aircraft.sync_from_maindb!
     Ygg::Acao::MainDb::Mezzo.update_last_update!
     puts "Aircraft done, took #{Time.new - time0} seconds" if debug >= 1
  end

  if Ygg::Acao::MainDb::Volo.has_been_updated?
    volo_changed = true
    time0 = Time.new

    puts "Updating Ygg::Acao::Flight" if debug >= 1

    Ygg::Acao::Flight.sync_from_maindb!(from_time: Time.now - 30.days, debug: debug)

    Ygg::Acao::MainDb::Volo.update_last_update!

    puts "Ygg::Acao::Flight done, took #{Time.new - time0} seconds" if debug >= 1
  end

  if Ygg::Acao::MainDb::LogBar2.has_been_updated?
    puts "LogBar2 has been changed" if debug >= 1
    logbar_changed = true

    Ygg::Acao::BarTransaction.sync_from_maindb!(from_time: Time.now - 30.days, debug: debug)

    Ygg::Acao::MainDb::LogBar2.update_last_update!
  end

  if Ygg::Acao::MainDb::CassettaBarLocale.has_been_updated?
    puts "CassettaBarLocale has been changed" if debug >= 1
    logbar_changed = true

    Ygg::Acao::BarTransaction.sync_from_maindb2!(from_time: Time.now - 30.days, debug: debug)

    Ygg::Acao::MainDb::CassettaBarLocale.update_last_update!
  end

  if Ygg::Acao::MainDb::LogBollini.has_been_updated?
    puts "LogBollini has been changed" if debug >= 1
    logbol_changed = true

    Ygg::Acao::TokenTransaction.sync_from_maindb!(from_time: Time.now - 30.days, debug: debug)

    Ygg::Acao::MainDb::LogBollini.update_last_update!
  end


  if onda_changed
    puts "Running trigger replacement" if debug >= 1
    time0 = Time.new
    Ygg::Acao::Onda::DocTesta.trigger_replacement(debug: debug)
    puts "trigger replacement done, took #{Time.new - time0} seconds" if debug >= 1
    Ygg::Acao::Onda::DocTesta.update_last_update!
  end

  if soci_changed || mezzo_changed || volo_changed || onda_changed || logbar_changed || logbol_changed
    puts "------------------------------- DONE ---------------------------------" if debug >= 1
  end

  sleep 5
end
