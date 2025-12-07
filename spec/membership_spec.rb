require "rails_helper"

RSpec.describe Ygg::Acao::Membership, type: :model do

  describe 'compute_completed_years' do
    it 'returns the years difference on the same day/month' do
      expect(Ygg::Acao::Membership.compute_completed_years(Time.new(1975,12,7), Time.new(2025,12,7))).to eq(50)
    end

    it 'returns a year less the day before' do
      expect(Ygg::Acao::Membership.compute_completed_years(Time.new(1975,12,7), Time.new(2025,12,6))).to eq(49)
    end

    it 'returns a year less the month is before' do
      expect(Ygg::Acao::Membership.compute_completed_years(Time.new(1975,12,7), Time.new(2025,11,8))).to eq(49)
    end
  end

end
