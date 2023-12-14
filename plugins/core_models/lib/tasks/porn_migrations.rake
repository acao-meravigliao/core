namespace :db do
  namespace :porn do
    desc 'Fucking better migrations'

    task :migrate => :environment do
      Ygg::Core::HasPornMigration.migrate_all

    end

    task :dry_migrate => :environment do
      Ygg::Core::HasPornMigration.migrate_all(dry_run: true)
    end

    task :diff => :environment do
      pp Ygg::Core::HasPornMigration.diff_all
    end

    def deep_diff(a,b)
      (a.keys | b.keys).inject({}) do |diff, k|
        if a[k] != b[k]
          if a[k].respond_to?(:deep_diff) && b[k].respond_to?(:deep_diff)
            diff[k] = a[k].deep_diff(b[k])
          else
            diff[k] = [a[k], b[k]]
          end
        end
        diff
      end
    end

    task :dump => :environment do
      schemas_path = File.join(Rails.root, 'db', 'schemas')
      FileUtils.mkdir(schemas_path) if !Dir.exists?(schemas_path)

      need_to_snapshot = false
      cur_schema = Ygg::Core::HasPornMigration.dump

      latest_schema_filename = Dir.open(File.join(Rails.root, 'db', 'schemas')).entries.select { |x| x =~ /^[0-9]{8}_[0-9]{6}\.yml$/ }.sort.last
      if latest_schema_filename
        latest_schema = YAML.load(File.read(File.join(schemas_path, latest_schema_filename)))
puts "LATEST (#{latest_schema_filename}) == #{Time.new.strftime('%Y%m%d_%H%M%S')}.json ========> #{deep_diff(latest_schema, cur_schema)}, #{latest_schema == cur_schema}"
        need_to_snapshot = true if latest_schema != cur_schema
      else
        need_to_snapshot = true
      end

      if need_to_snapshot
        File.write(File.join(schemas_path, "#{Time.new.strftime('%Y%m%d_%H%M%S')}.yml"), cur_schema.to_yaml)
      end
    end
  end
end
