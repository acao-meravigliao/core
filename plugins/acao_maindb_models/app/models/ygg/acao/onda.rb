module Ygg
module Acao
module Onda

module LastUpdateTracker
  def last_update
    # USE master;
    # GO
    # GRANT VIEW SERVER STATE TO lino;

    res = connection.exec_query("SELECT OBJECT_NAME(OBJECT_ID) AS DatabaseName, last_user_update,* " +
                                  "FROM sys.dm_db_index_usage_stats WHERE database_id = DB_ID('acao') " +
                                  "AND OBJECT_ID=OBJECT_ID('#{table_name}')")

    res[0] ? res[0]['last_user_update'] : nil
  end

  def get_lu
    Ygg::Acao::MainDb::LastUpdate.find_or_create_by!(tablename: table_name.to_s)
  end

  def has_been_updated?
    live_last_update = last_update
    return false if !live_last_update

    lu = get_lu
    lu.last_update != live_last_update ? live_last_update : nil
  end

  def update_last_update!(last: last_update)
    lu = get_lu
    lu.last_update = last
    lu.save!
  end
end

end
end
end
