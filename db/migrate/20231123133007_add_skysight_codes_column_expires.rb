class AddSkysightCodesColumnExpires < ActiveRecord::Migration[6.1]
  def change
    add_column 'acao.skysight_codes', 'expires_at', :timestamp
  end
end
