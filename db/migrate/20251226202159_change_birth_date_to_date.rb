class ChangeBirthDateToDate < ActiveRecord::Migration[8.1]
  def change
    change_column 'core.people', 'birth_date', 'date USING birth_date::date'
  end
end
