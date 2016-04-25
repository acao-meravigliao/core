
require 'net/ldap'
require 'net/ldap/dn'




ldap = Net::LDAP.new(
  host: 'localhost',
  port: 389,
  auth: {
    method: :simple,
    username: 'cn=admin,dc=acao,dc=it',
    password: 'dr400itbb',
 }
)

if !ldap.bind
  puts "Auth failed"
  exit
end


Ygg::Acao::MainDb::Socio.all.each do |socio|
  cn = (socio.Nome.strip + ' ' + socio.Cognome.strip).strip
  dn = "cn=#{Net::LDAP::DN.escape(cn)},ou=people,dc=acao,dc=it"

  attr = {
    cn: cn,
    objectclass: ['top', 'inetOrgPerson' ],
    sn: socio.Cognome.strip,
  }

  phone_office = socio.Telefono_Ufficio.gsub(/[^0-9]/, '').strip
  phone_home = socio.Telefono_Casa.gsub(/[^0-9]/, '').strip
  phone_mobile = socio.Telefono_Cellulare.gsub(/[^0-9]/, '').strip
  email = socio.Email.strip

  attr[:telephoneNumber] = phone_office unless phone_office.empty?
  attr[:homePhone] = phone_home unless phone_home.empty?
  attr[:mobile] = phone_mobile unless phone_mobile.empty?
  attr[:mail] = email unless email.empty?

  res = ldap.delete(dn: dn)
#  puts "DEL #{socio.id_soci_dati_generale} #{dn}: #{ldap.get_operation_result.to_s}" if !res

  res = ldap.add(dn: dn, attributes: attr)
  puts "ADD #{socio.id_soci_dati_generale} #{dn}: #{ldap.get_operation_result.to_s}" if !res
end

