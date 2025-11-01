class AddSatispayToPayment < ActiveRecord::Migration[8.0]
  def change
    add_column 'acao.payments', 'amount_paid', :decimal, precision: 14, scale: 6
    add_column 'acao.payments', 'sp_idempotency_key', :string
    add_column 'acao.payments', 'sp_id', :string
    add_column 'acao.payments', 'sp_code', :string
    add_column 'acao.payments', 'sp_type', :string
    add_column 'acao.payments', 'sp_status', :string
    add_column 'acao.payments', 'sp_status_ownership', :boolean
    add_column 'acao.payments', 'sp_expired', :boolean
    add_column 'acao.payments', 'sp_sender_id', :string
    add_column 'acao.payments', 'sp_sender_type', :string
    add_column 'acao.payments', 'sp_sender_name', :string
    add_column 'acao.payments', 'sp_sender_profile_picture', :string
    add_column 'acao.payments', 'sp_receiver_id', :string
    add_column 'acao.payments', 'sp_receiver_type', :string
    add_column 'acao.payments', 'sp_daily_closure_id', :string
    add_column 'acao.payments', 'sp_daily_closure_date', :timestamp
    add_column 'acao.payments', 'sp_insert_date', :timestamp
    add_column 'acao.payments', 'sp_expire_date', :timestamp
    add_column 'acao.payments', 'sp_description', :string
    add_column 'acao.payments', 'sp_flow', :string
    add_column 'acao.payments', 'sp_external_code', :string
    add_column 'acao.payments', 'sp_redirect_url', :string
    add_column 'acao.payments', 'sp_status_code', :integer

    drop_table 'acao.payment_satispay_charges'
  end
end
