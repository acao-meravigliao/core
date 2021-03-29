class RemovedUnusedTables < ActiveRecord::Migration[6.0]
  def change
    drop_table 'shop_agreements_acl'
    drop_table 'shop_billing_entries_acl'
    drop_table 'shop_invoices_acl'
    drop_table 'shop_packages_acl'
    drop_table 'shop_products_acl'
    drop_table 'shop_resellers_acl'
    drop_table 'ca_le_order_identifiers'
    drop_table 'ca_le_domain_challenges'
    drop_table 'ca_le_domains'
  end
end
