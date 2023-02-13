class AddLateRenewalDeadline < ActiveRecord::Migration[6.1]
  def change
    add_column 'acao.years', 'late_renewal_deadline', 'datetime'
    execute "UPDATE acao.years SET late_renewal_deadline = date(year || '-02-01')"
    change_column_null 'acao.years', 'late_renewal_deadline', false
  end
end
