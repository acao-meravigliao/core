class AddAgeReferenceDateToYear < ActiveRecord::Migration[8.1]
  def change
    add_column 'acao.years', 'age_reference_date', :date

    Ygg::Acao::Year.all.each { |x| x.update(age_reference_date: x.renew_opening_time || Time.new(x.year, 10, 26)) }

    change_column_null 'acao.years', 'age_reference_date', false
  end
end
