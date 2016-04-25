f = File.open('/opt/acao_dashboard/sql_timing.csv', 'a')

loop do
  start = Time.now

#  Ygg::Acao::MainDb::Socio.connection.reconnect!

  connect_t = Time.now

  a = Ygg::Acao::MainDb::Socio.all.to_a
  query_t = Time.now

  f.puts "#{Time.now},#{"%.5f" % ((connect_t - start) * 1000)},#{"%.5f" % ((query_t - connect_t) * 1000)},#{"%.5f" % ((query_t-start) * 1000)}"

#  Ygg::Acao::MainDb::Socio.connection.disconnect!

  sleep 5
end
