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

  onda_changed = false

  puts "loop" if debug >= 4

  if Ygg::Acao::Onda::DocTesta.has_been_updated?
    puts "DocTesta has been changed (other #{(Time.now - Ygg::Acao::Onda::DocTesta.last_update).to_i} old)" if debug >= 1
    onda_changed = true
  end

  if onda_changed
    Ygg::Acao::Member.transaction do
      puts "Running trigger replacement" if debug >= 1
      time0 = Time.new
      Ygg::Acao::Onda::DocTesta.trigger_replacement(debug: debug)
      puts "trigger replacement done, took #{Time.new - time0} seconds" if debug >= 1

      Ygg::Acao::Invoice.sync_from_maindb!(from_time: Time.now - 30.days, debug: debug)

      Ygg::Acao::Onda::DocTesta.update_last_update!
    end
  end

  if onda_changed
    puts "------------------------------- DONE ---------------------------------" if debug >= 1
  end

  sleep 5
end
