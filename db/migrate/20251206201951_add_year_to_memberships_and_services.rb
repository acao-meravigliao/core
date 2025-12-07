class AddYearToMembershipsAndServices < ActiveRecord::Migration[8.1]
  def up
    add_column 'acao.memberships', 'year', :integer
    add_column 'acao.member_services', 'year', :integer
    add_column 'acao.member_services', 'service_code', :string
    add_column 'acao.member_services', 'name', :string

    Ygg::Acao::Membership.all.each do |m|
      m.year = (m.valid_from + ((m.valid_to - m.valid_from) / 2)).year
      m.save!
    end

    Ygg::Acao::MemberService.all.each do |m|
      m.year = (m.valid_from + ((m.valid_to - m.valid_from) / 2)).year
      m.service_code = m.service_type.symbol
      m.name = m.service_type.name
      m.save!
    end

    change_column_null 'acao.memberships', 'year', false
    change_column_null 'acao.member_services', 'year', false
    change_column_null 'acao.member_services', 'service_code', false
  end
end
