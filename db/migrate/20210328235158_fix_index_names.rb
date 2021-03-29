class FixIndexNames < ActiveRecord::Migration[6.0]
  def change
    res = execute "select schemaname,indexname from pg_catalog.pg_indexes where indexname like '%.%';"
    res.each { |r| execute "ALTER INDEX #{r['schemaname']}.\"#{r['indexname']}\" RENAME TO #{r['indexname'].gsub(/^.*\.(.*)/, "index_\\1")}" }
  end
end
