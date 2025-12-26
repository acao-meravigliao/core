require "rails_helper"

RSpec.describe Ygg::Acao::Member, 'determine_required_ass_cav', type: :model do
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

  let(:year_model) {
    Ygg::Acao::Year.create!(
      year: time.year,
      renew_announce_time: Time.local(2025,10,26),
      late_renewal_deadline: Time.local(2026,1,31),
      age_reference_date: Time.local(2025,10,26),
    )
  }

  before(:each) {
    year_model
  }

  subject { member }

  context 'when is not instructor' do
    before(:each) do
#      member.roles.create!(symbol: 'SPL_INSTRUCTOR')
    end

    context 'when age is 18 before age_reference_date' do
      before(:each) {
        person.update(birth_date: Time.new(2007,10,1))
      }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is 22 before age_reference date' do
      before(:each) {
        person.update(birth_date: Time.new(2002,12,7))
      }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age turn 23 one day after age_reference date' do
      before(:each) {
        person.update(birth_date: Time.local(2002,10,27))
      }

      it 'returns ASS_23 and NO CAV ]' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is 23 on age_reference date' do
      before(:each) {
        person.update(birth_date: Time.new(2002,10,26))
      }

      it 'returns ASS_STANDARD and CAV_26' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_STANDARD', 'CAV_26' ])
      end
    end

    context 'when age is 23 one day after age_reference date' do
      before(:each) {
        person.update(birth_date: Time.new(2002,10,25))
      }

      it 'returns ASS_STANDARD and CAV_26' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_STANDARD', 'CAV_26' ])
      end
    end

    context 'when age is 30' do
      before(:each) {
        person.update(birth_date: Time.new(1996,10,1))
      }

      it 'returns ASS_STANDARD and CAV_STANDARD' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_STANDARD', 'CAV_STANDARD' ])
      end
    end

    context 'when age is >= 75' do
      before(:each) {
        person.update(birth_date: Time.new(1946,10,1))
      }

      it 'returns ASS_STANDARD and CAV_75' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_STANDARD', 'CAV_75' ])
      end
    end
  end

  context 'when is instructor' do
    before(:each) do
      member.roles.create!(symbol: 'SPL_INSTRUCTOR')
    end

    context 'when age is 18 before age_reference_date' do
      before(:each) {
        person.update(birth_date: Time.new(2007,10,1))
      }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is 22 before age_reference date' do
      before(:each) {
        person.update(birth_date: Time.new(2002,12,7))
      }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age turn 23 one day after age_reference date' do
      before(:each) {
        person.update(birth_date: Time.local(2002,10,27))
      }

      it 'returns ASS_23 and NO CAV ]' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is 23 on age_reference date' do
      before(:each) {
        person.update(birth_date: Time.new(2002,10,26))
      }

      it 'returns ASS_FI and CAV_26' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_FI', 'CAV_26' ])
      end
    end

    context 'when age is 23 one day after age_reference date' do
      before(:each) {
        person.update(birth_date: Time.new(2002,10,25))
      }

      it 'returns ASS_FI and CAV_26' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_FI', 'CAV_26' ])
      end
    end

    context 'when age is 30' do
      before(:each) {
        person.update(birth_date: Time.new(1996,10,1))
      }

      it 'returns ASS_FI and CAV_STANDARD' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_FI', 'CAV_STANDARD' ])
      end
    end

    context 'when age is >= 75' do
      before(:each) {
        person.update(birth_date: Time.new(1946,10,1))
      }

      it 'returns ASS_FI CAV_75' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_FI', 'CAV_75' ])
      end
    end
  end

  context 'when is cav_exempt' do
    before(:each) {
      member.update(cav_exempt: true)
    }

    context 'when age is 18 before age_reference_date' do
      before(:each) {
        person.update(birth_date: Time.new(2007,10,1))
      }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is 22 before age_reference date' do
      before(:each) {
        person.update(birth_date: Time.new(2002,12,7))
      }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age turn 23 one day after age_reference date' do
      before(:each) {
        person.update(birth_date: Time.local(2002,10,27))
      }

      it 'returns ASS_23 and NO CAV ]' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is 23 on age_reference date' do
      before(:each) {
        person.update(birth_date: Time.new(2002,10,26))
      }

      it 'returns ASS_STANDARD and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_STANDARD', nil ])
      end
    end

    context 'when age is 23 one day after age_reference date' do
      before(:each) {
        person.update(birth_date: Time.new(2002,10,25))
      }

      it 'returns ASS_STANDARD and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_STANDARD', nil ])
      end
    end

    context 'when age is 30' do
      before(:each) {
        person.update(birth_date: Time.new(1996,10,1))
      }

      it 'returns ASS_STANDARD and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_STANDARD', nil ])
      end
    end

    context 'when age is >= 75' do
      before(:each) {
        person.update(birth_date: Time.new(1946,10,1))
      }

      it 'returns ASS_STANDARD and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_STANDARD', nil ])
      end
    end
  end

  context 'when is cav_exempt and instructor' do
    before(:each) {
      member.update(cav_exempt: true)
      member.roles.create!(symbol: 'SPL_INSTRUCTOR')
    }

    context 'when age is 18 before age_reference_date' do
      before(:each) {
        person.update(birth_date: Time.new(2007,10,1))
      }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is 22 before age_reference date' do
      before(:each) {
        person.update(birth_date: Time.new(2002,12,7))
      }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age turn 23 one day after age_reference date' do
      before(:each) {
        person.update(birth_date: Time.local(2002,10,27))
      }

      it 'returns ASS_23 and NO CAV ]' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is 23 on age_reference date' do
      before(:each) {
        person.update(birth_date: Time.new(2002,10,26))
      }

      it 'returns ASS_FI and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_FI', nil ])
      end
    end

    context 'when age is 23 one day after age_reference date' do
      before(:each) {
        person.update(birth_date: Time.new(2002,10,25))
      }

      it 'returns ASS_FI and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_FI', nil ])
      end
    end

    context 'when age is 30' do
      before(:each) {
        person.update(birth_date: Time.new(1996,10,1))
      }

      it 'returns ASS_FI and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_FI', nil ])
      end
    end

    context 'when age is >= 75' do
      before(:each) {
        person.update(birth_date: Time.new(1946,10,1))
      }

      it 'returns ASS_FI and NO CAV' do
        expect(subject.determine_required_ass_cav(time: time)).to eq([ 'ASS_FI', nil ])
      end
    end

  end
end
