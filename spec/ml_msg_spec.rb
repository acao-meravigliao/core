require 'rails_helper'

RSpec.describe Ygg::Ml do
  let(:time) {
    Time.local(2025, 12, 7, 10, 30, 00)
  }

  let(:person) {
    r = Ygg::Core::Person.create(
      first_name: 'Paolino',
      last_name: 'Paperino',
    )

    r.emails.create(email: 'daniele@orlandi.com')
    r
  }

  let(:test_msg) {
    Ygg::Ml::Msg.create!(
      id: "fffffd39-b26c-44ae-87ef-1bfc8e559245",
      message:
"DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=acao.it; q=dns/txt; s=notifier; t=1603397514; bh=/3zMeEF3qM2MDeRJ9m8TG7KiSTiOgr+t6RNsJ5PQru0=; h=date:from:reply-to:to:message-id:subject:mime-version:content-type:content-transfer-encoding; b=YeNrx0T3P9IQ+cdjxbgY71aTVSxyZmV5fPiNDkadGvVrtpn9U0CEv62wsiqLu8yArDytewfhy5/VNXuetOtV7CXtd83BnW4wAy3uut5/9VPMN938l1QM1diYMNfNEgKYDvah5o4u8NApBglJBc/8+or13+fhKAg0bd/A5IAgtf8=
Return-Path: <b59a5026d35b1bf3219ffada3561f53c@bounces.acao.it>
Date: Thu, 22 Oct 2020 22:11:54 +0200
From: ACAO <info@acao.it>
Reply-To: info@acao.it
To: Luca Castelli <lucacastelli3@gmail.com>
Message-ID: b59a5026d35b1bf3219ffada3561f53c@bounces.acao.it
Subject: [ACAO] Conto Bar
Mime-Version: 1.0
Content-Type: multipart/signed;
 boundary=----7FF611BC81F2F4344DCB49409E37C27F;
 micalg=sha-256;
 protocol=\"application/x-pkcs7-signature\"
Content-Transfer-Encoding: 7bit
Auto-Submitted: auto-generated
X-Mailer: Yggdra Notifier
Content-Language: it
Organization: AeroClub Adele Orsi A.s.d.

This is an S/MIME signed message
------7FF611BC81F2F4344DCB49409E37C27F
Return-Path: <b59a5026d35b1bf3219ffada3561f53c@bounces.acao.it>
Date: Thu, 22 Oct 2020 22:11:54 +0200
From: ACAO <info@acao.it>
Reply-To: info@acao.it
To: Luca Castelli <lucacastelli3@gmail.com>
Message-ID: b59a5026d35b1bf3219ffada3561f53c@bounces.acao.it
Subject: [ACAO] Conto Bar
Mime-Version: 1.0
Content-Type: text/html;
 charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Auto-Submitted: auto-generated
X-Mailer: Yggdra Notifier
Content-Language: it
Organization: AeroClub Adele Orsi A.s.d.

<style>=0D
table.summary { font-size: 90%; width: 90%; min-width: 20em; max-width: 4=
0em; }=0D
.time { width: 2em; font-size: 80% }=0D
.count { width: 2em }=0D
.amount { width: 4em }=0D
.descr { }=0D
td.count { text-align: right  }=0D
td.amount { text-align: right; font-family: monospace; font-size: 120%; }=
=0D
tr.total td { border-top: dotted 1px; }=0D
tr.total td.amount { font-weight: bold; }=0D
tr.partial td { border-top: dotted 1px; border-bottom: dotted 1px; }=0D
tr.partial td.amount { font-weight: bold; }=0D
</style>=0D
=0D
<p>=0D
  Ciao Luca,=0D
</p>=0D
<p>=0D
  Nella giornata del 12-09-2020 il tuo conto bar ha subito dei movimenti.=
 Ecco un resoconto delle transazioni:=0D
</p>=0D
=0D
<table class=3D\"summary\">=0D
<thead>=0D
<tr>=0D
  <th class=3D\"time\">Ora</th>=0D
  <th class=3D\"count\">Num</th>=0D
  <th class=3D\"descr\">Descrizione</th>=0D
  <th class=3D\"amount\">Ammontare</th>=0D
</tr>=0D
</thead>=0D
=0D
<tbody>=0D
=0D
=0D
=0D
<tr class=3D\"partial\">=0D
  <td class=3D\"date\" colspan=3D3>12-09-2020</td>=0D
  <td class=3D\"amount\">-0.70 =E2=82=AC</td>=0D
</tr>=0D
=0D
=0D
<tr>=0D
  <td class=3D\"time\">09:31</td>=0D
  <td class=3D\"count\">1</td>=0D
  <td class=3D\"descr\">Caff=C3=A9</td>=0D
  <td class=3D\"amount\">-1.00 =E2=82=AC</td>=0D
</tr>=0D
=0D
=0D
=0D
=0D
<tr>=0D
  <td class=3D\"time\">15:55</td>=0D
  <td class=3D\"count\">1</td>=0D
  <td class=3D\"descr\">Birra 40dl</td>=0D
  <td class=3D\"amount\">-4.00 =E2=82=AC</td>=0D
</tr>=0D
=0D
=0D
=0D
=0D
<tr class=3D\"partial\">=0D
  <td class=3D\"date\" colspan=3D3>13-09-2020</td>=0D
  <td class=3D\"amount\">-5.70 =E2=82=AC</td>=0D
</tr>=0D
=0D
=0D
<tr>=0D
  <td class=3D\"time\">16:09</td>=0D
  <td class=3D\"count\">1</td>=0D
  <td class=3D\"descr\">Birra 40dl</td>=0D
  <td class=3D\"amount\">-4.00 =E2=82=AC</td>=0D
</tr>=0D
=0D
=0D
=0D
=0D
<tr>=0D
  <td class=3D\"time\">16:09</td>=0D
  <td class=3D\"count\">1</td>=0D
  <td class=3D\"descr\">Birra 40dl</td>=0D
  <td class=3D\"amount\">-4.00 =E2=82=AC</td>=0D
</tr>=0D
=0D
=0D
=0D
</tbody>=0D
=0D
<tfoot>=0D
<tr class=3D\"total\">=0D
  <td class=3D\"date\" colspan=3D3>13-09-2020</td>=0D
  <td class=3D\"amount\">-13.70 =E2=82=AC</td>=0D
</tr>=0D
</tfoot>=0D
=0D
</table>=0D
=0D
<p>=0D
Ciao,=0D
</p>=0D
=0D
<div class=3D\"moz-signature\">=0D
-- <br>=0D
&nbsp;&nbsp;Automaticamente tuo, ACAO=0D
</div>=

------7FF611BC81F2F4344DCB49409E37C27F
Content-Type: application/x-pkcs7-signature;
 name=smime.p7s
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename=smime.p7s

MIIODgYJKoZIhvcNAQcCoIIN/zCCDfsCAQExDzANBglghkgBZQMEAgEFADAL
BgkqhkiG9w0BBwGgggsSMIIFJDCCBAygAwIBAgIRAPt9VPnKoQLP7Ke/pwhI
n4IwDQYJKoZIhvcNAQELBQAwgZcxCzAJBgNVBAYTAkdCMRswGQYDVQQIExJH
cmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGjAYBgNVBAoT
EUNPTU9ETyBDQSBMaW1pdGVkMT0wOwYDVQQDEzRDT01PRE8gUlNBIENsaWVu
dCBBdXRoZW50aWNhdGlvbiBhbmQgU2VjdXJlIEVtYWlsIENBMB4XDTE4MTAx
MjAwMDAwMFoXDTE5MTAxMjIzNTk1OVowHTEbMBkGCSqGSIb3DQEJARYMaW5m
b0BhY2FvLml0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA20P6
B7NyM0m6+C66wHw89/gSk3LyXESqGmgowgAr7puWC2ZGX/WforvPkLjtA2xL
cH7mXATM7xGQdrW7znv2aWhzTZI9qtjSFrYBzO6wIFsO9DiazB+rtBiMp1eB
CKOv4wh4HbjKGshoaus2wXKD6lbI66dwV8+3vOEoGv6CdFjbhrdwdPGP3of+
bLLHUT3uyIS0QBPSSWBTEJf0EW/uRwWnNfTGCoiYjSRZ12QFpSGKkAGNeccc
NAEJXQo2SP+MFEDgUD0FZ7OX9LPWfUCMH8PLkTvFUP9NjE3qPftX5PcIpEnh
r38r++KPcT2kRwoItWTVp+qa6aG4DRrAN3UenQIDAQABo4IB4jCCAd4wHwYD
VR0jBBgwFoAUgq9sjPjF/pZhfOgfPStxSF7Ei8AwHQYDVR0OBBYEFKsirnJQ
sEb6oq93dE2dYMQyqZu2MA4GA1UdDwEB/wQEAwIFoDAMBgNVHRMBAf8EAjAA
MCAGA1UdJQQZMBcGCCsGAQUFBwMEBgsrBgEEAbIxAQMFAjARBglghkgBhvhC
AQEEBAMCBSAwRgYDVR0gBD8wPTA7BgwrBgEEAbIxAQIBAQEwKzApBggrBgEF
BQcCARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLm5ldC9DUFMwWgYDVR0fBFMw
UTBPoE2gS4ZJaHR0cDovL2NybC5jb21vZG9jYS5jb20vQ09NT0RPUlNBQ2xp
ZW50QXV0aGVudGljYXRpb25hbmRTZWN1cmVFbWFpbENBLmNybDCBiwYIKwYB
BQUHAQEEfzB9MFUGCCsGAQUFBzAChklodHRwOi8vY3J0LmNvbW9kb2NhLmNv
bS9DT01PRE9SU0FDbGllbnRBdXRoZW50aWNhdGlvbmFuZFNlY3VyZUVtYWls
Q0EuY3J0MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20w
FwYDVR0RBBAwDoEMaW5mb0BhY2FvLml0MA0GCSqGSIb3DQEBCwUAA4IBAQA+
YFHRGnnvRtMZNT4XL+qJ4HKihH4pF0E80Vw04FDQUNHYk8ycYhZzjqXpAyyj
2FbFfDlPj/07HvR476scBzPP0c3rfkTrU4TYc2Ooeh/BLmnW2qgFV+EyMYGw
gZEi3iHk38VfKc22KFA0rNs67eIUUFo9zTcIGm0Z6FsXemfxKyGF2l04Zn+8
4m88LerFyaNCA4WijtDP9c11GuVCIsTaRTuO8tkgahcly/OYVA5cbRm0y2gW
jwFqN1xqj3wX+SdnbkR/iOByPsUqAkXvlMPZOcCEcrzO01XzVSw5Mc0aIkO2
OUArGH2J4Vob1qdjoFRD+XWZwfZHFVP54GrxgokvMIIF5jCCA86gAwIBAgIQ
apvhODv/K2ufAdXZuKdSVjANBgkqhkiG9w0BAQwFADCBhTELMAkGA1UEBhMC
R0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2Fs
Zm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxKzApBgNVBAMTIkNP
TU9ETyBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTMwMTEwMDAw
MDAwWhcNMjgwMTA5MjM1OTU5WjCBlzELMAkGA1UEBhMCR0IxGzAZBgNVBAgT
EkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UE
ChMRQ09NT0RPIENBIExpbWl0ZWQxPTA7BgNVBAMTNENPTU9ETyBSU0EgQ2xp
ZW50IEF1dGhlbnRpY2F0aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0EwggEiMA0G
CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC+s55XrCh2dUAWxzgDmNPGGHYh
UPMleQtMtaDRfTpYPpynMS6n9jR22YRq2tA9NEjk6vW7rN/5sYFLIP1of3l0
NKZ6fLWfF2VgJ5cijKYy/qlAckY1wgOkUMgzKlWlVJGyK+UlNEQ1/5ErCsHq
9x9aU/x1KwTdF/LCrT03Rl/FwFrf1XTCwa2QZYL55AqLPikFlgqOtzk06kb2
qvGlnHJvijjI03BOrNpo+kZGpcHsgyO1/u1OZTaOo8wvEU17VVeP1cHWse9t
GKTDyUGg2hJZjrqck39UIm/nKbpDSZ0JsMoIw/JtOOg0JC56VzQgBo7ictRe
TQE5LFLG3yQK+xS1AgMBAAGjggE8MIIBODAfBgNVHSMEGDAWgBS7r34CPfqm
8TyEjq3uOJjs2TIy1DAdBgNVHQ4EFgQUgq9sjPjF/pZhfOgfPStxSF7Ei8Aw
DgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwEQYDVR0gBAow
CDAGBgRVHSAAMEwGA1UdHwRFMEMwQaA/oD2GO2h0dHA6Ly9jcmwuY29tb2Rv
Y2EuY29tL0NPTU9ET1JTQUNlcnRpZmljYXRpb25BdXRob3JpdHkuY3JsMHEG
CCsGAQUFBwEBBGUwYzA7BggrBgEFBQcwAoYvaHR0cDovL2NydC5jb21vZG9j
YS5jb20vQ09NT0RPUlNBQWRkVHJ1c3RDQS5jcnQwJAYIKwYBBQUHMAGGGGh0
dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAeFyy
gSg0TzzuX1bOn5dW7I+iaxf28/ZJCAbU2C81zd9A/tNx4+jsQgwRGiHjZrAY
ayZrrm78hOx7aEpkfNPQIHGG6Fvq3EzWf/Lvx7/hk6zSPwIal9v5IkDcZoFD
7f3iT7PdkHJY9B51csvU50rxpEg1OyOT8fk2zvvPBuM4qQNqbGWlnhMpIMwp
WZT89RY0wpJO+2V6eXEGGHsROs3njeP9DqqqAJaBa4wBeKOdGCWn1/Jp2oY6
dyNmNppI4ZNMUH4Tam85S1j6E95u4+1Nuru84OrMIzqvISE2HN/56ebTOWlc
rurffade2022O/tUU1gb4jfWCcyvB8czm12FgX/y/lRjmDbEA08QJNB2729Y
+io1IYO3ztveBdvUCIYZojTq/OCR6MvnzS6X72HP0PRLRTiOSEmIDsS5N5w/
8IW1Hva5hEFy6fDAfd9yI+O+IMMAj1KcL/Zo9jzJ16HO5m60ttl1Enk8MQkz
/W3JlHaeI5iKFn4UJu1/cP2YHXYPiWf2JyBzsLBrGk1II+3yL8aorYew6CQv
dVifC3HtwlSam9V1niiCfOBe2C12TdKGu05LWIA3ZkFcWJGaNXOZ6Ggyh/Tq
vXG5v7zmEVDNXFnHn9tFpMpOUvxhcsjycBtH0dZ0WrNw6gH+HF8TIhCnH3+z
zWuDN0Rk6h9KVkfKehIxggLAMIICvAIBATCBrTCBlzELMAkGA1UEBhMCR0Ix
GzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9y
ZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxPTA7BgNVBAMTNENPTU9E
TyBSU0EgQ2xpZW50IEF1dGhlbnRpY2F0aW9uIGFuZCBTZWN1cmUgRW1haWwg
Q0ECEQD7fVT5yqECz+ynv6cISJ+CMA0GCWCGSAFlAwQCAQUAoIHkMBgGCSqG
SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIwMTAyMjIw
MTE1NFowLwYJKoZIhvcNAQkEMSIEIE5lBqBHTe7b4cF9R9KhmuWsd2nKq42F
/4MexKRpcx0pMHkGCSqGSIb3DQEJDzFsMGowCwYJYIZIAWUDBAEqMAsGCWCG
SAFlAwQBFjALBglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwIC
AgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMA0G
CSqGSIb3DQEBAQUABIIBAASFUH4EbgldPofPQdvFy1T8om6zAxzyhVjv10Wl
DsziqpToPQiERegLuxNeaGg+mjhByzL+ChXHlhU16R/JnD7TTcgOO4NIIZPo
ixBNKlRKAwJX0lQU7vlzfMvu+FsLUPlbsfQc9OOt2T7ZqV7ANFu3KFLBIMOK
0+A07zH8bRTUwXxD1E3m5jxdtKBMuNQOJ2yZz8lH7wifQqxqnRAD+xQNfBBu
59ZdeU9zHFvaMoZzZHlsJDqEQqqW7g6hSPHfgyk1GRNVs1xAMTgW2SSn8nP7
bw6FLMLhmYheCwjB+QrTuWQArN26mp1nZkinkadRnuNR/VZYsVVawNcaDFd4
xKg=

------7FF611BC81F2F4344DCB49409E37C27F--
".replace("\n", "\r\n"),
      abstract: "[ACAO] Conto Bar",
      created_at: '2020-10-22 20:11:54.945593000 UTC +00:00',
      delivery_started_at: '2020-10-22 20:11:54.969450000 UTC +00:00',
      email_message_id: "b59a5026d35b1bf3219ffada3561f53c",
      status: "ASSUMED_DELIVERED",
      type: "Ygg::Ml::Msg::Email",
      updated_at: '2020-10-29 22:02:40.469675000 UTC +00:00',
      receipt_code: nil,
      delivery_successful_at: '2020-10-29 22:02:40.468218000 UTC +00:00',
      delivery_last_attempt_at: '2020-10-22 20:11:54.969457000 UTC +00:00',
      email_mdn_request: false,
      email_data_response: "250 2.0.0 Ok: queued as 0D142ED3",
      skebby_order: nil,
      submitted_at: '2020-10-22 20:11:55.095749000 UTC +00:00',
      status_reason: nil,
      skebby_status: nil,
      retry_at: nil,
      person_id: "da93d9a7-4485-4f69-aca0-721f8f3cb4e7",
      recipient_id: "f95c969d-7ebb-4772-94c3-92341bd5a8ba",
      sender_id: "167b00b3-677d-4616-b5df-c6414b440d06"
    )
  }

  let(:language_it) {
    Ygg::I18n::Language.create!(
       id: '5507650d-d8c2-48b0-81d5-e8e5474bdd02',
       iso_639_3: 'ita',
       descr: 'Italiano',
       iso_639_1: 'it'
    )
  }

  let(:template) {
    Ygg::Ml::Template.create!(
      created_at: '2017-11-17 12:45:55.667504000 +0000',
      updated_at: '2024-10-12 19:31:31.163647000 +0000',
      id: 'f2798661-55a0-4abd-8e5c-faca390a1aa0',
      symbol: 'TEST_TEMPLATE',
      subject: '[TEST] 123',
      body: "\nCiao <%=first_name%>,\n",
      additional_headers: '',
      content_type: 'text/plain',
      language: language_it,
    )
  }

  let(:ca_rsa_key) {
    OpenSSL::PKey::RSA.new(2048)
  }

  let(:sender_rsa_key) {
    OpenSSL::PKey::RSA.new(2048)
  }

  let(:ca_cert) {
    cert_attrs = {
     'C'  => 'US',
     'ST' => 'SomeState',
      'L' => 'SomeCity',
      'O' => 'Organization',
     'OU' => 'Organizational Unit',
     'CN' => 'somesite.com',
    }

    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 1
    cert.subject = OpenSSL::X509::Name.new(cert_attrs.map { |k, v| [ k, v ] })
    cert.issuer = cert.subject
    cert.public_key = ca_rsa_key.public_key
    cert.not_before = time
    cert.not_after = time + (360 * 24 * 3600)

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert
    cert.extensions = [
      ef.create_extension('basicConstraints','CA:TRUE', true),
      ef.create_extension('keyUsage','keyCertSign, cRLSign', true),
      ef.create_extension('subjectKeyIdentifier', 'hash', false),
    ]

    cert.add_extension(
      ef.create_extension('authorityKeyIdentifier', 'keyid:always', false)
    )

    cert.sign ca_rsa_key, OpenSSL::Digest::SHA256.new

    cert
  }

  let(:sender_cert) {
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 1
    cert.subject = OpenSSL::X509::Name.new([[ 'CN', 'Foo Bar' ], [ 'emailAddress', 'test@test.it' ]])
    cert.issuer = ca_cert.subject
    cert.public_key = sender_rsa_key.public_key
    cert.not_before = time
    cert.not_after = time + (360 * 24 * 3600)

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = ca_cert
    cert.extensions = [
      ef.create_extension('basicConstraints','CA:FALSE', true),
      ef.create_extension('subjectKeyIdentifier', 'hash'),
      ef.create_extension('extendedKeyUsage', 'critical, emailProtection'),
    ]

    cert.sign ca_rsa_key, OpenSSL::Digest::SHA256.new

    cert
  }

  require 'tmpdir'

  let(:key_store) {
    tempdir = Dir.mktmpdir

    Ygg::Ca::KeyStore::Local.create!(
      symbol: 'YGGDRA',
      descr: 'Testing keystore',
      local_directory: tempdir,
    )
  }

  let(:dkim_rsa_key) {
    OpenSSL::PKey::RSA.new(1024)
  }

  let(:dkim_key_pair) {
    ksp = key_store.generate_pair(key_type: 'RSA', key_length: 1024)

    Ygg::Ca::KeyPair.find_by!(public_key_hash: ksp.public_key_hash)
  }

  let(:sender) {
    key_file = Tempfile.create
    key_file.write sender_rsa_key.to_pem
    key_file.close

    cert_file = Tempfile.create
    cert_file.write sender_cert.to_pem
    cert_file.close

    Ygg::Ml::Sender.create!(
      id: '167b00b3-677d-4616-b5df-c6414b440d06',
      name: 'Test Sender',
      symbol: 'TEST_SENDER',
      descr: '',
      email_address: 'TEST <test@test.it>',
      email_signing_key_filename: key_file.path,
      email_signing_cert_filename: cert_file.path,
      email_bounces_domain: 'bounces.acao.it',
      email_reply_to: 'info@acao.it',
      email_organization: 'AeroClub Adele Orsi A.s.d.',
      email_smtp_pars:
       {'hostname'=>'smarthost.vihai.it', 'domain'=>'yo.orlandi.com', 'tls_mode'=>'no'},
      email_dkim_selector: 'notifier',
      email_dkim_key_pair: dkim_key_pair,
      skebby_username: 'acao',
      skebby_password: 'carmelina1',
      skebby_sender_number: nil,
      skebby_sender_string: nil,
      skebby_token: 't6iFkC00R8s2CobLmso0I57Y',
      skebby_user_key: '3336519',
    )
  }

  describe Ygg::Ml::Template, type: :model do
    it 'gets processed and produces correct text output' do
      res = template.process(first_name: 'Foo')

      expect(res).to be_a(Hash)
      expect(res[:body]).to eq("\nCiao Foo,\n")
      expect(res[:email_headers]).to match({})
      expect(res[:subject]).to eq("[TEST] 123")
    end
  end

  describe Ygg::Ml::Msg::Email, type: :model do
    it 'is created by ::notify' do

      msgs = Ygg::Ml::Msg::Email.notify(
        sender: sender,
        destinations: person,
        template: template,
        template_context: { first_name: 'Paolino' },
        objects: [],
        msg_attrs: {},
        exclude_addrs: [],
        flush: true,
      )

      expect(msgs.count).to eq(1)

      msg = msgs.first

      expect(msg.abstract).to eq('[TEST] 123')
      expect(msg.status).to eq('NEW')

      msg.finalize!

      expect(msg.status).to eq('PENDING')

    end
  end

end
