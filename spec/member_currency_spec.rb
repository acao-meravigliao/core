require "rails_helper"

RSpec.describe Ygg::Acao::Member, type: :model do
  let(:time) {
    Time.local(2025, 12, 7, 10, 30, 00)
  }

  let(:person) {
    Ygg::Core::Person.create!(
      first_name: 'Paolino',
      last_name: 'Paperino',
    )
  }

  let(:member) {
    Ygg::Acao::Member.create!(
      person: person,
    )
  }

  let(:year) {
    Ygg::Acao::Year.create!(
      year: time.year,
      renew_announce_time: time.beginning_of_year,
      late_renewal_deadline: time.end_of_year,
    )
  }

  let(:service_type_association) {
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

  let(:service_type_cav) {
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

  let(:flight_gld_pic_1101) {
    member.flights.create!(
      takeoff_time: Time.local(2025, 11, 1, 11, 11, 11),
      landing_time: Time.local(2025, 11, 1, 12, 13, 14),
      aircraft_class: 'GLD',
      launch_type: 'TOW',
      aircraft_reg: 'D-1234',
      takeoff_location_raw: 'LILC',
      landing_location_raw: 'LILC',
      pilot1_role: 'PIC',
      pilot1_name: member.person.name,
      proficiency_check: false,
      skill_test: false,
      maintenance_flight: false,
      purpose: nil,
    )
  }

  let(:flight_gld_pic_1002) {
    member.flights.create!(
      takeoff_time: Time.local(2025, 10, 2, 13, 14, 15),
      landing_time: Time.local(2025, 10, 2, 16, 17, 19),
      aircraft_class: 'GLD',
      launch_type: 'TOW',
      aircraft_reg: 'D-1234',
      takeoff_location_raw: 'LILC',
      landing_location_raw: 'LILC',
      pilot1_role: 'PIC',
      pilot1_name: member.person.name,
      proficiency_check: false,
      skill_test: false,
      maintenance_flight: false,
      purpose: nil,
    )
  }

  let(:flight_gld_pic_0915) {
    member.flights.create!(
      takeoff_time: Time.local(2025, 9, 15, 10, 11, 12),
      landing_time: Time.local(2025, 9, 15, 11, 12, 13),
      aircraft_class: 'GLD',
      launch_type: 'TOW',
      aircraft_reg: 'D-1234',
      takeoff_location_raw: 'LILC',
      landing_location_raw: 'LILC',
      pilot1_role: 'PIC',
      pilot1_name: member.person.name,
      proficiency_check: false,
      skill_test: false,
      maintenance_flight: false,
      purpose: nil,
    )
  }

  let(:flight_gld_pax_1103) {
    member.flights.create!(
      takeoff_time: Time.local(2025, 11, 3, 10, 11, 12),
      landing_time: Time.local(2025, 11, 3, 11, 12, 13),
      aircraft_class: 'GLD',
      launch_type: 'TOW',
      aircraft_reg: 'D-1234',
      takeoff_location_raw: 'LILC',
      landing_location_raw: 'LILC',
      pilot1_role: 'PAX',
      pilot1_name: member.person.name,
      proficiency_check: false,
      skill_test: false,
      maintenance_flight: false,
      purpose: nil,
    )
  }

  let(:flight_sep_pic_1103) {
    member.flights.create!(
      takeoff_time: Time.local(2025, 11, 3, 10, 11, 12),
      landing_time: Time.local(2025, 11, 3, 11, 12, 13),
      aircraft_class: 'SEP',
      launch_type: 'TOW',
      aircraft_reg: 'D-1234',
      takeoff_location_raw: 'LILC',
      landing_location_raw: 'LILC',
      pilot1_role: 'PAX',
      pilot1_name: member.person.name,
      proficiency_check: false,
      skill_test: false,
      maintenance_flight: false,
      purpose: nil,
    )
  }

  subject {
    member.compute_currency
  }

  context 'without membership' do
#    it 'produces currency with ass' do
#      expect(member.person).to eq(person)
#    end
  end

  context 'with valid membership' do
    let(:membership) {
      member.memberships.create!(
        valid_from: time.beginning_of_year,
        valid_to: time.end_of_year,
        reference_year: year,
      )
    }

    before(:each) do
      membership
    end

    context 'with association' do
      let(:ass) {
        member.services.create!(
          valid_from: time.beginning_of_year,
          valid_to: time.end_of_year,
          service_type: service_type_association,
        )
      }

      before(:each) do
        membership
        ass
      end

      it 'has valid association' do
        expect(subject[:ass][:valid]).to be_truthy
      end

      it 'association valid until end of year' do
        expect(subject[:ass][:until]).to be_within(1).of(time.end_of_year)
      end

      context 'with CAV' do
        let(:cav) {
          member.services.create!(
            valid_from: time.beginning_of_year,
            valid_to: time.end_of_year,
            service_type: service_type_cav,
          )
        }

        before(:each) do
          cav
        end

        it 'has valid CAV' do
          expect(subject[:cav][:valid]).to be_truthy
        end

        context 'with one flight as PIC in the last 30 days' do
          before(:each) do
            flight_gld_pic_1101
          end

          it 'does not indicate three_gld_launches_in_90_days' do
            expect(subject[:three_gld_launches_in_90_days][:valid]).to be_falsey
          end

          it 'shows three_gld_launches_in_90_days_until as nil' do
            expect(subject[:three_gld_launches_in_90_days][:until]).to be_nil
          end
        end

        context 'with two flight as PIC in the last 30 days' do
          before(:each) do
            flight_gld_pic_1101
            flight_gld_pic_1002
          end

          it 'does not indicate three_gld_launches_in_90_days' do
            expect(subject[:three_gld_launches_in_90_days][:valid]).to be_falsey
          end

          it 'shows three_gld_launches_in_90_days_until as nil' do
            expect(subject[:three_gld_launches_in_90_days][:until]).to be_nil
          end
        end

        context 'with two flight as PIC and one as PAX in the last 30 days' do
          before(:each) do
            flight_gld_pic_1101
            flight_gld_pic_1002
            flight_gld_pax_1103
          end

          it 'does not indicate three_gld_launches_in_90_days' do
            expect(subject[:three_gld_launches_in_90_days][:valid]).to be_falsey
          end

          it 'shows three_gld_launches_in_90_days_until as nil' do
            expect(subject[:three_gld_launches_in_90_days][:until]).to be_nil
          end
        end

        context 'with two flight as PIC and one as PIC in SEP in the last 30 days' do
          before(:each) do
            flight_gld_pic_1101
            flight_gld_pic_0915
            flight_sep_pic_1103
          end

          it 'does not indicate three_gld_launches_in_90_days' do
            expect(subject[:three_gld_launches_in_90_days][:valid]).to be_falsey
          end

          it 'shows three_gld_launches_in_90_days_until as nil' do
            expect(subject[:three_gld_launches_in_90_days][:until]).to be_nil
          end
        end

        context 'with three flight as PIC in the last 30 days' do
          before(:each) do
            flight_gld_pic_1101
            flight_gld_pic_1002
            flight_gld_pic_0915
          end

          it 'does indicate three_gld_launches_in_90_days' do
            expect(subject[:three_gld_launches_in_90_days][:valid]).to be_truthy
          end

          it 'shows three_gld_launches_in_90_days_until as close to 2025-12-14' do
            expect(subject[:three_gld_launches_in_90_days][:until]).to be_within(2).of(Time.local(2025, 12, 15))
          end
        end

      end
    end
  end
end
