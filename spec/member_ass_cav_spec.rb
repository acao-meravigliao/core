require "rails_helper"

RSpec.describe Ygg::Acao::Member, 'determine_required_ass_cav', type: :model do
  let(:time) {
    Time.local(2025, 12, 7, 10, 30, 00)
  }

  let(:person) {
    Ygg::Core::Person.create!(
      first_name: 'Paolino',
      last_name: 'Paperino',
      birth_date: Date.new(1975, 12, 7),
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

    context 'when age is 18 at time of renewal' do
      let(:time) { Time.local(1993, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 1994 }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is 22 at time of renewal' do
      let(:time) { Time.local(1998, 10, 7, 10, 30, 0) }
      let(:renewal_year) { 1999 }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is exactly 23 at time of renewal' do
      let(:time) { Time.local(1998, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 1999 }

      it 'returns ASS_STANDARD and CAV_26' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', 'CAV_26' ])
      end
    end

    context 'when age is one day after 23 at time of renewal' do
      let(:time) { Time.local(1998, 12, 8, 10, 30, 0) }
      let(:renewal_year) { 1999 }

      it 'returns ASS_STANDARD and CAV_26' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', 'CAV_26' ])
      end
    end

    context 'when age is one day before 27 at time of renewal' do
      let(:time) { Time.local(2002, 12, 6, 10, 30, 0) }
      let(:renewal_year) { 2003 }

      it 'returns ASS_STANDARD and CAV_26' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', 'CAV_26' ])
      end
    end

    context 'when age is exactly 27 at time of renewal' do
      let(:time) { Time.local(2002, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2003 }

      it 'returns ASS_STANDARD and CAV_STANDARD' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', 'CAV_STANDARD' ])
      end
    end

    context 'when age is 30 at time of renewal' do
      let(:time) { Time.local(2005, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2006 }

      it 'returns ASS_STANDARD and CAV_STANDARD' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', 'CAV_STANDARD' ])
      end
    end

    context 'when age is >= 75 at time of renewal but not at 31-1 of renewal year' do
      let(:time) { Time.local(2049, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2050 }

      it 'returns ASS_STANDARD and CAV_75' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', 'CAV_STANDARD' ])
      end
    end

    context 'when age is >= 75 at 31-1 of renewal year' do
      let(:time) { Time.local(2051, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2051 }

      it 'returns ASS_STANDARD and CAV_75' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', 'CAV_75' ])
      end
    end
  end

  context 'when is instructor' do
    before(:each) do
      member.roles.create!(symbol: 'SPL_INSTRUCTOR')
    end

    context 'when age is 18 at time of renewal' do
      let(:time) { Time.local(1993, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 1994 }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is 22 at time of renewal' do
      let(:time) { Time.local(1998, 10, 7, 10, 30, 0) }
      let(:renewal_year) { 1999 }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is exactly 23 at time of renewal' do
      let(:time) { Time.local(1998, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 1999 }

      it 'returns ASS_STANDARD and CAV_26' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', 'CAV_26' ])
      end
    end

    context 'when age is one day after 23 at time of renewal' do
      let(:time) { Time.local(1998, 12, 8, 10, 30, 0) }
      let(:renewal_year) { 1999 }

      it 'returns ASS_STANDARD and CAV_26' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', 'CAV_26' ])
      end
    end

    context 'when age is one day before 27 at time of renewal' do
      let(:time) { Time.local(2002, 12, 6, 10, 30, 0) }
      let(:renewal_year) { 2003 }

      it 'returns ASS_STANDARD and CAV_26' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', 'CAV_26' ])
      end
    end

    context 'when age is exactly 27 at time of renewal' do
      let(:time) { Time.local(2002, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2003 }

      it 'returns ASS_STANDARD and CAV_STANDARD' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', 'CAV_STANDARD' ])
      end
    end

    context 'when age is 30 at time of renewal' do
      let(:time) { Time.local(2005, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2006 }

      it 'returns ASS_STANDARD and CAV_STANDARD' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', 'CAV_STANDARD' ])
      end
    end

    context 'when age is >= 75 at time of renewal but not at 31-1 of renewal year' do
      let(:time) { Time.local(2049, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2050 }

      it 'returns ASS_STANDARD and CAV_75' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', 'CAV_STANDARD' ])
      end
    end

    context 'when age is >= 75 at 31-1 of renewal year' do
      let(:time) { Time.local(2051, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2051 }

      it 'returns ASS_STANDARD and CAV_75' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', 'CAV_75' ])
      end
    end
  end

  context 'when is cav_exempt' do
    before(:each) {
      member.update(cav_exempt: true)
    }

    context 'when age is 18 at time of renewal' do
      let(:time) { Time.local(1993, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 1994 }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is 22 at time of renewal' do
      let(:time) { Time.local(1998, 10, 7, 10, 30, 0) }
      let(:renewal_year) { 1999 }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is exactly 23 at time of renewal' do
      let(:time) { Time.local(1998, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 1999 }

      it 'returns ASS_STANDARD and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', nil ])
      end
    end

    context 'when age is one day after 23 at time of renewal' do
      let(:time) { Time.local(1998, 12, 8, 10, 30, 0) }
      let(:renewal_year) { 1999 }

      it 'returns ASS_STANDARD and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', nil ])
      end
    end

    context 'when age is one day before 27 at time of renewal' do
      let(:time) { Time.local(2002, 12, 6, 10, 30, 0) }
      let(:renewal_year) { 2003 }

      it 'returns ASS_STANDARD and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', nil ])
      end
    end

    context 'when age is exactly 27 at time of renewal' do
      let(:time) { Time.local(2002, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2003 }

      it 'returns ASS_STANDARD and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', nil ])
      end
    end

    context 'when age is 30 at time of renewal' do
      let(:time) { Time.local(2005, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2006 }

      it 'returns ASS_STANDARD and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', nil ])
      end
    end

    context 'when age is >= 75 at time of renewal but not at 31-1 of renewal year' do
      let(:time) { Time.local(2049, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2050 }

      it 'returns ASS_STANDARD and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', nil ])
      end
    end

    context 'when age is >= 75 at 31-1 of renewal year' do
      let(:time) { Time.local(2051, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2051 }

      it 'returns ASS_STANDARD and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_STANDARD', nil ])
      end
    end

  end

  context 'when is cav_exempt and instructor' do
    before(:each) {
      member.update(cav_exempt: true)
      member.roles.create!(symbol: 'SPL_INSTRUCTOR')
    }

    context 'when age is 18 at time of renewal' do
      let(:time) { Time.local(1993, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 1994 }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is 22 at time of renewal' do
      let(:time) { Time.local(1998, 10, 7, 10, 30, 0) }
      let(:renewal_year) { 1999 }

      it 'returns ASS_23 and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_23', nil ])
      end
    end

    context 'when age is exactly 23 at time of renewal' do
      let(:time) { Time.local(1998, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 1999 }

      it 'returns ASS_FI and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', nil ])
      end
    end

    context 'when age is one day after 23 at time of renewal' do
      let(:time) { Time.local(1998, 12, 8, 10, 30, 0) }
      let(:renewal_year) { 1999 }

      it 'returns ASS_FI and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', nil ])
      end
    end

    context 'when age is one day before 27 at time of renewal' do
      let(:time) { Time.local(2002, 12, 6, 10, 30, 0) }
      let(:renewal_year) { 2003 }

      it 'returns ASS_FI and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', nil ])
      end
    end

    context 'when age is exactly 27 at time of renewal' do
      let(:time) { Time.local(2002, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2003 }

      it 'returns ASS_FI and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', nil ])
      end
    end

    context 'when age is 30 at time of renewal' do
      let(:time) { Time.local(2005, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2006 }

      it 'returns ASS_FI and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', nil ])
      end
    end

    context 'when age is >= 75 at time of renewal but not at 31-1 of renewal year' do
      let(:time) { Time.local(2049, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2050 }

      it 'returns ASS_FI and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', nil ])
      end
    end

    context 'when age is >= 75 at 31-1 of renewal year' do
      let(:time) { Time.local(2051, 12, 7, 10, 30, 0) }
      let(:renewal_year) { 2051 }

      it 'returns ASS_FI and NO CAV' do
        expect(subject.determine_required_ass_cav(renewal_year: renewal_year, time: time)).to eq([ 'ASS_FI', nil ])
      end
    end

  end
end
