class ChangeRosterDayForeignKey < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key 'acao.roster_entries', column: 'roster_day_id'
    add_foreign_key 'acao.roster_entries', 'acao.roster_days', column: 'roster_day_id', on_delete: :cascade
  end
end
