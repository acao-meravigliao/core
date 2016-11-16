require 'securerandom'

namespace :acao do
  desc 'Sync tables'

  task(:'sync:planes' => :environment) do

    Ygg::Acao::MainDb::Mezzo.where('numero_flarm <> \'id\'').all.each do |mezzo|

      registration = mezzo.Marche.strip.upcase
      flarm_id = mezzo.numero_flarm.strip.upcase

      puts "UPD #{flarm_id} = #{registration}"

      p = Ygg::Acao::Plane.find_by_flarm_id('flarm:' + flarm_id)
      if !p
        Ygg::Acao::Plane.create(
          registration: registration,
          flarm_id: 'flarm:' + flarm_id,
          uuid: SecureRandom.uuid,
        )
      else
        p.registration = mezzo.Marche.strip.upcase
        p.save!
      end

    end

  end

  task('sync:frequent' => :environment) do
    Ygg::Acao::Flight.sync_frequent!
  end


  task(:'sync:flarmnet' => :environment) do
    Ygg::Acao::Plane.import_flarmnet_db!
  end

  task(:'sync:flights' => :environment) do
    Ygg::Acao::Flight.sync!
  end

  task(:'sync:ml:soci' => :environment) do
    r_records = nil
    l_records = nil

    r_emails = { 'adrisand@libero.it' =>  'Don Adriano Sandri' }

    r_results = Ygg::Acao::MainDb::Socio.connection.select_rows("
      SELECT ana.RagioneSociale AS socio, sdg.email
      FROM
      ( SELECT  DISTINCT(fatt.idAnagrafica) AS id
         FROM acao.dbo.ATTDocTeste AS fatt
         INNER JOIN acao.dbo.ATTDocRighe r
           ON fatt.IdDoc = r.IdDoc
           AND r.CodArt in ('0001S', '0003S', '0004S', '0007S', '00G1S')
         WHERE -- associazione anno dal 1 Nov
          fatt.DataDocumento >= '#{Date.new((Time.now-13.month).year, 11)}'
          AND fatt.tipoDocumento = 6   -- 6=ricevuta fiscale
      ) AS isc
      INNER JOIN acao.dbo.STDAnagraficaClienti AS cli ON isc.id = cli.idAnagrafica
      INNER JOIN acao.dbo.STDAnagrafiche AS ana ON isc.id = ana.idAnagrafica
      INNER JOIN acao_pro.dbo.soci_dati_generale AS sdg ON sdg.codice_socio_dati_generale = cli.rifInterno
      ORDER BY sdg.email")

    r_results.map { |x| [ x[0], x[1].strip.downcase ] }.
              select { |x| !x[1].empty? && x[1] != 'acao@acao.it' }.
              each { |x|
      r_emails[x[1]] = x[0]
    }

    l_emails = IO::popen([ '/usr/bin/ssh', '-i', '/opt/acao_public/iserver', 'root@lists.acao.it', '/usr/sbin/list_members', 'soci' ]).read.split("\n").map { |x| x.strip.downcase }.sort!

    members_to_add = []
    members_to_remove = []

    r_enum = r_emails.keys.sort!.each
    l_enum = l_emails.each

    r = r_enum.next rescue nil
    l = l_enum.next rescue nil

    while r || l
      if !l || (r && r < l)
        members_to_add << "#{r_emails[r]} <#{r}>"

        r = r_enum.next rescue nil
      elsif !r || (l && r > l)
        members_to_remove << l
        l = l_enum.next rescue nil
      else
        l = l_enum.next rescue nil
        r = r_enum.next rescue nil
      end
    end

    puts "ANNUNCI MEMBERS TO ADD = #{members_to_add.join("\n")}"
    puts "ANNUNCI MEMBERS TO REMOVE = #{members_to_remove.join("\n")}"

    if members_to_add.any?
      io = IO::popen([ '/usr/bin/ssh', '-i', '/opt/acao_public/iserver', 'root@lists.acao.it', '/usr/sbin/add_members', '-r', '-', '--admin-notify=n', '--welcome-msg=n', 'soci' ], 'w')
      io.write(members_to_add.join("\n"))
      io.close
    end

    if members_to_remove.any?
      io = IO::popen([ '/usr/bin/ssh', '-i', '/opt/acao_public/iserver', 'root@lists.acao.it', '/usr/sbin/remove_members', '--file', '-', '--nouserack', '--noadminack', 'soci' ], 'w')
      io.write(members_to_remove.join("\n"))
      io.close
    end
  end

  task(:'sync:pilots' => :environment) do
    r_records = nil
    l_records = nil

    added_records = []
    removed_records = []
    updated_records = []

    ActiveRecord::Base.transaction do

      r_records = Ygg::Acao::MainDb::Socio.all.joins(:iscrizioni).merge(Ygg::Acao::MainDb::SocioIscritto.where(:anno_iscrizione => 2014)).order(:codice_socio_dati_generale => :asc)
      l_records = Ygg::Core::Person.where('acao_code IS NOT NULL').order(:acao_code => :asc)

      r_enum = r_records.each
      l_enum = l_records.each

      r = r_enum.next rescue nil
      l = l_enum.next rescue nil

      while r || l
#puts "#{l ? l.acao_code : 'NIL'} VS #{r ? r.codice_socio_dati_generale : 'NIL'}"
        if l && !l.acao_code
          # Ignore
          l = l_enum.next rescue nil
        elsif !l || (r && r.codice_socio_dati_generale < l.acao_code)
puts "ADDING SOCIO CODICE=#{r.codice_socio_dati_generale}"

          person = Ygg::Core::Person.create!({
            :acao_code => r.codice_socio_dati_generale,
            :first_name => r.Nome.blank? ? '?' : r.Nome,
            :last_name => r.Cognome,
            :gender => r.Sesso,
            :residence_location => Ygg::Core::Location.new_for([ r.Via, r.Citta, r.Provincia, r.CAP, r.Stato ].join(', ')),
            :birth_date => r.Data_Nascita,
            :birth_location => Ygg::Core::Location.new_for([ r.Nato_a ].join(', ')),
            :italian_fiscal_code => r.Codice_Fiscale,
          })

          sleep 0.5

          r_email = (r.Email && !r.Email.strip.empty? && r.Email.strip != 'acao@acao.it') ? r.Email.strip : nil

          person.channels << Ygg::Core::Channel.new(:channel_type => 'email', :value => r_email) if r_email
          person.channels << Ygg::Core::Channel.new(:channel_type => 'phone', :value => r.Telefono_Casa, :descr => 'Casa') if r.Telefono_Casa
          person.channels << Ygg::Core::Channel.new(:channel_type => 'phone', :value => r.Telefono_Ufficio, :descr => 'Ufficio') if r.Telefono_Ufficio
          person.channels << Ygg::Core::Channel.new(:channel_type => 'phone', :value => r.Telefono_Altro, :descr => 'Ufficio') if r.Telefono_Altro
          person.channels << Ygg::Core::Channel.new(:channel_type => 'mobile', :value => r.Telefono_Cellulare) if r.Telefono_Cellulare
          person.channels << Ygg::Core::Channel.new(:channel_type => 'fax', :value => r.Fax) if r.Fax
          person.channels << Ygg::Core::Channel.new(:channel_type => 'url', :value => r.Sito_Web) if r.Sito_Web

          person.identities << Ygg::Core::Identity.new({
            :qualified => r.codice_socio_dati_generale.to_s + '@legacy.acao.it',
            :credentials => [ Ygg::Core::Identity::Credential::HashedPassword.new(:password => r.Password.strip) ],
          })

          person.identities << Ygg::Core::Identity.new({
            :qualified => r.Email.strip,
            :credentials => [ Ygg::Core::Identity::Credential::HashedPassword.new(:password => r.Password.strip) ],
          })

          added_records << r

          r = r_enum.next rescue nil
        elsif !r || (l && r.codice_socio_dati_generale > l.acao_code)
puts "REMOVED SOCIO #{l.first_name} #{l.last_name}"
          l.acao_ext_id = l.acao_code
          l.acao_code = nil
          l.save!

#          removed_records << l

          l = l_enum.next rescue nil
        else
          r_email = (r.Email && !r.Email.strip.empty? && r.Email.strip != 'acao@acao.it') ? r.Email.strip : nil

          echan = l.channels.find_by_channel_type('email')
          l_email = echan ? echan.value : nil

          updated_records << {
            :local => l.clone,
            :remote => r.clone,
            :old_email => l_email,
            :new_email => r_email,
          }
puts "UPDATED SOCIO #{l.first_name} #{l.last_name}"
if l_email != r_email
  puts "UPD Email #{l_email} => #{r_email}"
end

          # We do not remove the old email FIXME
          l.identities.each do |i|
            i.credentials.each do |x|
              if (x.class == Ygg::Core::Identity::Credential::HashedPassword ||
                 x.class == Ygg::Core::Identity::Credential::ObfuscatedPassword) &&
                 !x.match_by_password(r.Password.strip)
                x.password = r.Password.strip
                x.save!
              end
            end
          end

          if r_email && !l.identities.find_by_qualified(r_email)
            l.identities << Ygg::Core::Identity.new({
              :qualified => r_email,
              :credentials => [ Ygg::Core::Identity::Credential::HashedPassword.new(:password => r.Password.strip) ],
            })
          elsif r_email && l.identities.find_by_qualified(r_email)
            l.identities.find_by_qualified(r_email).delete
          end

          if l_email && !r_email
            l.channels.where(:channel_type => 'email', :value => l_email).delete_all
          elsif !l_email && r_email
            l.channels << Ygg::Core::Channel.new(:channel_type => 'email', :value => r_email) if r_email
          elsif l_email != r_email
            echan.value = r_email
            echan.save!
          end

          l = l_enum.next rescue nil
          r = r_enum.next rescue nil
        end
      end
    end

    # Merge soci ML
    ####################################################à

    r_emails = {}

    fucked_emails = [
      'no',
      'acao@acao.it',
    ]

    r_records.select { |x| !x.Email.empty? }.each { |x|
      x.Email.strip.downcase.split(';').each { |y|
        if !fucked_emails.include?(y)
          r_emails[y] = "#{x.Nome} #{x.Cognome}"
        end
      }
    }

    l_emails = IO::popen([ '/usr/bin/ssh', '-i', '/opt/acao_public/iserver', 'root@lists.acao.it', '/usr/sbin/list_members', 'soci' ]).read.split("\n").map { |x| x.strip.downcase }.sort!

    members_to_add = []
    members_to_remove = []

    r_enum = r_emails.keys.sort!.each
    l_enum = l_emails.each

    r = r_enum.next rescue nil
    l = l_enum.next rescue nil

    while r || l
      if !l || (r && r < l)
        members_to_add << "#{r_emails[r]} <#{r}>"

        r = r_enum.next rescue nil
      elsif !r || (l && r > l)
        members_to_remove << l
        l = l_enum.next rescue nil
      else
        l = l_enum.next rescue nil
        r = r_enum.next rescue nil
      end
    end

    puts "ANNUNCI MEMBERS TO ADD = #{members_to_add}"
    puts "ANNUNCI MEMBERS TO REMOVE = #{members_to_remove}"

#    if members_to_add.any?
#      io = IO::popen([ '/usr/bin/ssh', '-i', '/opt/acao/acao', 'lists.acao.it', '/usr/sbin/add_members', '-r', '-', '--admin-notify=n', '--welcome-msg=n', 'soci' ], 'w')
#      io.write(members_to_add.join("\n"))
#      io.close
#    end
#
#    if members_to_remove.any?
#      io = IO::popen([ '/usr/bin/ssh', '-i', '/opt/acao/acao', 'lists.acao.it', '/usr/sbin/remove_members', '--file', '-', '--nouserack', '--noadminack', 'soci' ], 'w')
#      io.write(members_to_remove.join("\n"))
#      io.close
#    end

    # Update blabla ML
    ###############################

    members_to_add = added_records.select { |x| x.Email.strip != 'acao@acao.it' }.map { |x| "#{x.Nome} #{x.Cognome} <#{x.Email}>" }

    updated_records.each do |upd|
      if upd[:old_email] && !upd[:new_email]
        members_to_remove << upd[:old_email]
      elsif !upd[:old_email] && upd[:new_email]
        members_to_add << "#{upd[:remote].Nome} #{upd[:remote].Cognome} <#{upd[:new_email]}>"
      elsif upd[:old_email] != upd[:new_email]
        members_to_add << "#{upd[:remote].Nome} #{upd[:remote].Cognome} <#{upd[:new_email]}>"
        members_to_remove << upd[:old_email]
      end
    end


    puts "BLABLA MEMBERS TO ADD = #{members_to_add.join("\n")}"
    puts "BLABLA MEMBERS TO REMOVE = #{members_to_remove.join("\n")}"

#    if members_to_add.any?
#      io = IO::popen([ '/usr/bin/ssh', '-i', '/opt/acao/acao', 'lists.acao.it', '/usr/sbin/add_members', '-r', '-', 'blabla' ], 'w')
#      io.write(members_to_add.join("\n"))
#      io.close
#    end
#
#    if members_to_remove.any?
#      io = IO::popen([ '/usr/bin/ssh', '-i', '/opt/acao/acao', 'lists.acao.it', '/usr/sbin/remove_members', '--file', '-', 'blabla' ], 'w')
#      io.write(members_to_remove.join("\n"))
#      io.close
#    end
  end

  task(:sync => [ :'sync:flarmnet', :'sync:flights', :'sync:pilots' ]) do
  end
end
