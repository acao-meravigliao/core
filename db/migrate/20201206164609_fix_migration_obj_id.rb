class FixMigrationObjId < ActiveRecord::Migration[6.0]
  def change
    types = ActiveRecord::Base.connection.query('SELECT obj_type FROM core.replicas GROUP BY obj_type').flatten

    poly = {
     'Ygg::Dreg::Nameserver' => 'dreg.nameservers',
     'Ygg::Hosting::Proxy' => 'hst.proxies',
     'Ygg::Hosting::Server' => 'hst.servers',
     'Ygg::Hosting::DbServer' => 'hst.db_servers',
     'Ygg::Hosting::Site' => 'hst.sites',
     'Ygg::Email::SubmissionServer' => 'email.submission_servers',
     'Ygg::Email::SubmissionServer::SpfV4Network' => 'email.submission_server_spf_v4networks',
     'Ygg::Email::SubmissionServer::SpfV6Network' => 'email.submission_server_spf_v6networks',
     'Ygg::Email::Relay' => 'email.relays',
     'Ygg::Email::PopServer' => 'email.pop_servers',
     'Ygg::Email::Domain' => 'email.domains',
     'Ygg::Email::Forward' => 'email.forwards',
     'Ygg::Email::Mailbox' => 'email.mailboxes',
     'Ygg::Backup::Source' => 'bck.sources',
     'Ygg::Dns::Server' => 'dns.servers',
     'Ygg::Dns::Zone' => 'dns.zones',
     'Ygg::Sevio::Imprinter' => 'sevio.imprinters',
     'Ygg::Sevio::NetAccount' => 'sevio.net_accounts',
     'Ygg::Sevio::Access' => 'sevio.accesses',
     'Ygg::Sevio::AccessNode' => 'sevio.access_nodes',
     'Ygg::Sevio::Device' => 'sevio.devices',
     'Ygg::Sevio::Concentrator' => 'sevio.concentrators',
     'Ygg::Sevio::RDevice' => 'sevio.r_devices',
    }.slice(*types)

    poly.each do |cls, table|
      execute "UPDATE core.replicas SET obj_id=(SELECT id FROM #{table} WHERE id_old=obj_id_old) WHERE obj_type='#{cls}'"
    end
  end
end
