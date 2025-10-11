#! /usr/bin/ruby

debug = 2

puts "---------------- Watcher Started ----------------" if debug >= 1

ino = File.stat(__FILE__).ino

loop do

  cur_ino = File.stat(__FILE__).ino

  puts "#{__FILE__} cur_ino=#{cur_ino} ino=#{ino}" if debug >= 4

  if cur_ino != ino
    puts "==================== WATCHER REPLACED, RELOADING ====================="
    exit
  end

  soci_changed = false
  mezzo_changed = false
  volo_changed = false
  onda_changed = false
  logbar_changed = false
  logbol_changed = false
  tessera_changed = false

  puts "loop" if debug >= 4

  if Ygg::Acao::MainDb::Socio.has_been_updated?
    puts "Socio has been changed (other #{(Time.now - Ygg::Acao::MainDb::Socio.last_update).to_i} old)" if debug >= 1
    soci_changed = true
  end

  if Ygg::Acao::MainDb::SociDatiLicenza.has_been_updated?
    puts "SociDatiLicenza has been changed (other #{(Time.now - Ygg::Acao::MainDb::SociDatiLicenza.last_update).to_i} old)" if debug >= 1
    soci_changed = true
  end

  if Ygg::Acao::MainDb::SociDatiVisita.has_been_updated?
    puts "SociDatiVisita has been changed (other #{(Time.now - Ygg::Acao::MainDb::SociDatiVisita.last_update).to_i} old)" if debug >= 1
    soci_changed = true
  end

  if Ygg::Acao::MainDb::SocioIscritto.has_been_updated?
    puts "SocioIscritto has been changed (other #{(Time.now - Ygg::Acao::MainDb::SocioIscritto.last_update).to_i} old)" if debug >= 1
    soci_changed = true
  end

  if Ygg::Acao::MainDb::Mezzo.has_been_updated?
    puts "Mezzo has been changed" if debug >= 1
    soci_changed = true
    mezzo_changed = true
  end

  if Ygg::Acao::Onda::DocTesta.has_been_updated?
    puts "DocTesta has been changed (other #{(Time.now - Ygg::Acao::Onda::DocTesta.last_update).to_i} old)" if debug >= 1
    onda_changed = true
  end

  if Ygg::Acao::MainDb::Tessera.has_been_updated?
    puts "Tessera has been changed (other #{(Time.now - Ygg::Acao::MainDb::Tessera.last_update).to_i} old)" if debug >= 1
    tessera_changed = true
  end

  if soci_changed
    Ygg::Acao::Member.transaction do
      puts "Updating Member(s)" if debug >= 1

      time0 = Time.new
      Ygg::Acao::Member.sync_from_maindb!(debug: debug)
      puts "Member update done, took #{Time.new - time0} seconds" if debug >= 1
    end
  end

  if mezzo_changed
    Ygg::Acao::Member.transaction do
      time0 = Time.new
      puts "Updating Ygg::Acao::Aircraft" if debug >= 1

      Ygg::Acao::Aircraft.transaction do
        Ygg::Acao::Aircraft.sync_from_maindb!
        Ygg::Acao::MainDb::Mezzo.update_last_update!
      end

      puts "Aircraft done, took #{Time.new - time0} seconds" if debug >= 1
    end
  end

  if Ygg::Acao::MainDb::Volo.has_been_updated?
    Ygg::Acao::Member.transaction do
      volo_changed = true
      time0 = Time.new

      puts "Updating Ygg::Acao::Flight" if debug >= 1

      Ygg::Acao::Flight.sync_from_maindb!(from_time: Time.now - 30.days, debug: debug)

      Ygg::Acao::MainDb::Volo.update_last_update!

      puts "Ygg::Acao::Flight done, took #{Time.new - time0} seconds" if debug >= 1
    end
  end

  if Ygg::Acao::MainDb::LogBar2.has_been_updated?
    Ygg::Acao::Member.transaction do
      puts "LogBar2 has been changed" if debug >= 1
      logbar_changed = true

      Ygg::Acao::BarTransaction.sync_from_maindb!(from_time: Time.now - 30.days, debug: debug)

      Ygg::Acao::MainDb::LogBar2.update_last_update!
    end
  end

  if Ygg::Acao::MainDb::CassettaBarLocale.has_been_updated?
    Ygg::Acao::Member.transaction do
      puts "CassettaBarLocale has been changed" if debug >= 1
      logbar_changed = true

      Ygg::Acao::BarTransaction.sync_from_maindb2!(from_time: Time.now - 30.days, debug: debug)

      Ygg::Acao::MainDb::CassettaBarLocale.update_last_update!
    end
  end

  if Ygg::Acao::MainDb::LogBollini.has_been_updated?
    Ygg::Acao::Member.transaction do
      puts "LogBollini has been changed" if debug >= 1
      logbol_changed = true

      Ygg::Acao::TokenTransaction.sync_from_maindb!(from_time: Time.now - 30.days, debug: debug)

      Ygg::Acao::MainDb::LogBollini.update_last_update!
    end
  end


  if onda_changed
    Ygg::Acao::Member.transaction do
    end
  end

  if tessera_changed
    Ygg::Acao::Member.transaction do
      puts "Tessera has been changed" if debug >= 1

      Ygg::Acao::KeyFob.sync_from_maindb!(debug: debug)
      Ygg::Acao::MemberAccessRemote.sync_from_maindb!(debug: debug)

      Ygg::Acao::MainDb::Tessera.update_last_update!
    end
  end

  if soci_changed
    Ygg::Acao::Member.transaction do
      Ygg::Acao::MainDb::Socio.update_last_update!
      Ygg::Acao::MainDb::SociDatiLicenza.update_last_update!
      Ygg::Acao::MainDb::SociDatiVisita.update_last_update!
      Ygg::Acao::MainDb::SocioIscritto.update_last_update!
    end
  end

  if tessera_changed || soci_changed
    time0 = Time.new
    puts "  FAAC update started" if debug >= 1
    Ygg::Acao::Member.sync_with_faac!(debug: 1)
    puts "  FAAC update done, took #{Time.new - time0} seconds" if debug >= 1
  end

  if soci_changed || mezzo_changed || volo_changed || onda_changed || logbar_changed || logbol_changed
    puts "------------------------------- DONE ---------------------------------" if debug >= 1
  end

  sleep 5
end
