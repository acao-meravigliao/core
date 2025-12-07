require "rails_helper"

RSpec.describe Ygg::Acao::Membership, type: :model do
  let(:time) {
    Time.local(2025, 12, 10, 10, 30, 00)
  }

  let(:person) {
    p = Ygg::Core::Person.create(
      first_name: 'Paolino',
      last_name: 'Paperino',
      birth_date: Time.new(1975,12,7),
    )

    p.emails.create(email: 'daniele@orlandi.com')
    p
  }

  let(:member) {
    Ygg::Acao::Member.create!(
      person: person,
    )
  }

  let(:year_model) {
    Ygg::Acao::Year.create!(
      year: time.year,
      renew_announce_time: time.beginning_of_year,
      late_renewal_deadline: time.end_of_year,
      age_reference_date: Time.new(time.year, 10, 26),
    )
  }

  let(:ml_sender) {
    Ygg::Ml::Sender.create!(
      id: '167b00b3-677d-4616-b5df-c6414b440d06',
      name: 'ACAO',
      symbol: 'INFO_ACAO',
      descr: '',
      email_address: 'ACAO <info@acao.it>',
      email_signing_key_filename: '/etc/ssl/private/info@acao.it.key',
      email_signing_cert_filename: '/etc/ssl/private/info@acao.it.cert',
      email_bounces_domain: 'bounces.acao.it',
      email_reply_to: 'info@acao.it',
      email_organization: 'AeroClub Adele Orsi A.s.d.',
      email_smtp_pars:
       {'hostname'=>'smarthost.vihai.it', 'domain'=>'yo.orlandi.com', 'tls_mode'=>'no'},
      #email_dkim_selector: 'notifier',
      #email_dkim_key_pair_id: '3a9e1f4a-6daa-46b6-8130-33227f65fdc2',
      skebby_username: 'acao',
      skebby_password: '',
      skebby_sender_number: nil,
      skebby_sender_string: nil,
      skebby_token: '',
      skebby_user_key: '3336519',
    )
  }

  let(:ml_template_membership_renewed) {
    Ygg::Ml::Template.create!(
      created_at: '2017-11-17 12:46:39.694351000 +0000',
      updated_at: '2025-10-26 13:32:51.350653000 +0000',
      id: '2b737743-f814-487f-a31e-5da257b640d4',
      symbol: 'MEMBERSHIP_RENEWED',
      subject: '[ACAO] Rinnovo iscrizione',
      body: "\nCiao <%=first_name%>,\n\nL'iscrizione all'anno <%=year=> è stata ricevuta",
      additional_headers: '',
      content_type: 'text/plain',
    )
  }

  let(:service_type_ass_standard) {
    Ygg::Acao::ServiceType.create!(
      symbol: 'ASS_STANDARD',
      name: 'Quota associativa',
      price: 900,
      onda_1_code: '0001S',
      onda_1_cnt: 1,
      onda_1_type: 2,
      is_association: true,
      is_cav: false,
    )
  }

  let(:service_type_ass_23) {
    Ygg::Acao::ServiceType.create!(
      symbol: 'ASS_23',
      name: 'Quota associativa < 23 anni',
      price: 400,
      onda_1_code: '00G1S',
      onda_1_cnt: 1,
      onda_1_type: 2,
      is_association: true,
      is_cav: false,
    )
  }

  let(:service_type_ass_fi) {
    Ygg::Acao::ServiceType.create!(
      symbol: 'ASS_FI',
      name: 'Quota associativa istruttori',
      price: 300,
      onda_1_code: '0096S',
      onda_1_cnt: 1,
      onda_1_type: 2,
      is_association: true,
      is_cav: false,
    )
  }

  let(:service_type_cav_standard) {
    Ygg::Acao::ServiceType.create!(
      symbol: 'CAV_STANDARD',
      name: 'CAV standard',
      price: 1000,
      onda_1_code: '0002S',
      onda_1_cnt: 1,
      onda_1_type: 2,
      is_association: false,
      is_cav: true,
    )
  }

  let(:service_type_cav_26) {
    Ygg::Acao::ServiceType.create!(
      symbol: 'CAV_26',
      name: 'CAV 23-26 anni',
      price: 500,
      onda_1_code: '0002S',
      onda_1_cnt: 1,
      onda_1_type: 2,
      is_association: false,
      is_cav: true,
    )
  }

  let(:service_type_cav_75) {
    Ygg::Acao::ServiceType.create!(
      symbol: 'CAV_75',
      name: 'CAV > 75 anni',
      price: 500,
      onda_1_code: '0005S',
      onda_1_cnt: 1,
      onda_1_type: 2,
      is_association: false,
      is_cav: true,
    )
  }

  let(:service_type_cav_dis) {
    Ygg::Acao::ServiceType.create!(
      symbol: 'CAV_DIS',
      name: 'CAV persone con disabilità',
      price: 500,
      onda_1_code: '0009S',
      onda_1_cnt: 1,
      onda_1_type: 2,
      is_association: false,
      is_cav: true,
    )
  }

  let(:service_type_caa) {
    Ygg::Acao::ServiceType.create!(
      symbol: 'CAA',
      name: 'Contributo Alianti Club, senza aliante privato',
      price: 300,
      onda_1_code: '0003S',
      onda_1_cnt: 1,
      onda_1_type: 2,
      is_association: false,
      is_cav: false,
    )
  }

  let(:service_type_cap) {
    Ygg::Acao::ServiceType.create!(
      symbol: 'CAP',
      name: 'Contributo Alianti Club, con aliante privato',
      price: 150,
      onda_1_code: '0004S',
      onda_1_cnt: 1,
      onda_1_type: 2,
      is_association: false,
      is_cav: false,
    )
  }

  before :each do
    ml_sender
    ml_template_membership_renewed
    service_type_ass_standard
    service_type_ass_23
    service_type_ass_fi
    service_type_cav_standard
    service_type_cav_26
    service_type_cav_75
    service_type_cav_dis
    service_type_caa
    service_type_cap
  end

  describe 'determine_base_services' do
    context 'with 18-year (at age_reference_date) person' do
      it 'returns ASS_23, no CAV, services' do
        person.update(birth_date: Time.new(2007,12,7))

        bs = Ygg::Acao::Membership.determine_base_services(member: member, year_model: year_model, now: time)

        expect(bs).to match_array([
          hash_including({ service_type_id: service_type_ass_23.id }),
          hash_including({ service_type_id: service_type_cap.id }),
          hash_including({ service_type_id: service_type_caa.id }),
        ])
      end
    end

    context 'with 22-year (at age_reference_date) person' do
      it 'returns ASS_23, no CAV, services' do
        person.update(birth_date: Time.new(2002,12,7))

        bs = Ygg::Acao::Membership.determine_base_services(member: member, year_model: year_model, now: time)

        expect(bs).to match_array([
          hash_including({ service_type_id: service_type_ass_23.id }),
          hash_including({ service_type_id: service_type_cap.id }),
          hash_including({ service_type_id: service_type_caa.id }),
        ])
      end
    end

    context 'with 23-year (at age_reference_date) person' do
      it 'returns ASS_STANDARD, CAV_26, services' do
        person.update(birth_date: Time.new(2001,12,7))

        bs = Ygg::Acao::Membership.determine_base_services(member: member, year_model: year_model, now: time)

        expect(bs).to match_array([
          hash_including({ service_type_id: service_type_ass_standard.id }),
          hash_including({ service_type_id: service_type_cav_26.id }),
          hash_including({ service_type_id: service_type_cap.id }),
          hash_including({ service_type_id: service_type_caa.id }),
        ])
      end
    end

    context 'with 25-year (at age_reference_date) person' do
      it 'returns ASS_STANDARD, CAV_26, services' do
        person.update(birth_date: Time.new(1999,12,7))

        bs = Ygg::Acao::Membership.determine_base_services(member: member, year_model: year_model, now: time)

        expect(bs).to match_array([
          hash_including({ service_type_id: service_type_ass_standard.id }),
          hash_including({ service_type_id: service_type_cav_26.id }),
          hash_including({ service_type_id: service_type_cap.id }),
          hash_including({ service_type_id: service_type_caa.id }),
        ])
      end
    end

    context 'with 26-year (at age_reference_date) person' do
      it 'returns ASS_STANDARD, CAV_26, services' do
        person.update(birth_date: Time.new(1998,12,7))

        bs = Ygg::Acao::Membership.determine_base_services(member: member, year_model: year_model, now: time)

        expect(bs).to match_array([
          hash_including({ service_type_id: service_type_ass_standard.id }),
          hash_including({ service_type_id: service_type_cav_26.id }),
          hash_including({ service_type_id: service_type_cap.id }),
          hash_including({ service_type_id: service_type_caa.id }),
        ])
      end
    end

    context 'with 27-year (at age_reference_date) person' do
      it 'returns ASS_STANDARD, CAV_STANDARD, services' do
        person.update(birth_date: Time.new(1997,12,7))

        bs = Ygg::Acao::Membership.determine_base_services(member: member, year_model: year_model, now: time)

        expect(bs).to match_array([
          hash_including({ service_type_id: service_type_ass_standard.id }),
          hash_including({ service_type_id: service_type_cav_standard.id }),
          hash_including({ service_type_id: service_type_cap.id }),
          hash_including({ service_type_id: service_type_caa.id }),
        ])
      end
    end

    context 'with 50-year (at age_reference_date) person' do
      it 'returns ASS_STANDARD, CAV_STANDARD, services' do
        person.update(birth_date: Time.new(1975,12,7))

        bs = Ygg::Acao::Membership.determine_base_services(member: member, year_model: year_model, now: time)

        expect(bs).to match_array([
          hash_including({ service_type_id: service_type_ass_standard.id }),
          hash_including({ service_type_id: service_type_cav_standard.id }),
          hash_including({ service_type_id: service_type_cap.id }),
          hash_including({ service_type_id: service_type_caa.id }),
        ])
      end
    end

    context 'with 74-year (at age_reference_date) person' do
      it 'returns ASS_STANDARD, CAV_STANDARD, services' do
        person.update(birth_date: Time.new(1950,12,7))

        bs = Ygg::Acao::Membership.determine_base_services(member: member, year_model: year_model, now: time)

        expect(bs).to match_array([
          hash_including({ service_type_id: service_type_ass_standard.id }),
          hash_including({ service_type_id: service_type_cav_standard.id }),
          hash_including({ service_type_id: service_type_cap.id }),
          hash_including({ service_type_id: service_type_caa.id }),
        ])
      end
    end

    context 'with 75-year (at age_reference_date) person' do
      it 'returns ASS_STANDARD, CAV_75, services' do
        person.update(birth_date: Time.new(1949,12,7))

        bs = Ygg::Acao::Membership.determine_base_services(member: member, year_model: year_model, now: time)

        expect(bs).to match_array([
          hash_including({ service_type_id: service_type_ass_standard.id }),
          hash_including({ service_type_id: service_type_cav_75.id }),
          hash_including({ service_type_id: service_type_cap.id }),
          hash_including({ service_type_id: service_type_caa.id }),
        ])
      end
    end
  end

  context 'with 50-year old person' do
    it 'just doesn\'t raise exceptions' do

      Ygg::Acao::Membership.renew(
        member: member,
        year_model: year_model,
        services: [
          { service_type_id: service_type_ass_standard.id, enabled: true },
          { service_type_id: service_type_cav_standard.id, enabled: true },
          { service_type_id: service_type_caa.id, enabled: false },
          { service_type_id: service_type_cap.id, enabled: false },
        ],
        selected_roster_days: [ ],
      )
    end

    # Check that it creates membership
    # Check that it creates member_service
  end

end
