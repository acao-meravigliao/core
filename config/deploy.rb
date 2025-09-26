require 'mina/rails'

set :application_name, 'acao-core'
set :user, 'yggdra'
set :shared_dirs, fetch(:shared_dirs, []) + [ ]
set :shared_files, fetch(:shared_files, []) + [ 'config/database.yml', 'config/credentials.yml.enc', 'config/master.key' ]
set :repository, 'foobar'
set :keep_releases, 100
set :rsync_excludes, [
  '.git*',
  '/config/database.yml',
  '/config/credentials.yml.enc',
  '/config/master.key',
  '/vendor/bundle',
  '/tmp/cache',
  '/log',
  '/.env*.local',
].map { |x| "--exclude \"#{x}\"" }.join(' ')

task :environment do
end

task :setup do
  command %[touch "#{fetch(:deploy_to)}/shared/config/database.yml"]
  comment "Be sure to edit 'shared/config/database.yml'."
  comment "Be sure to edit 'shared/config/credentials.yml.enc' with 'rails credentials:edit'."
end

task :restart do
  comment 'Restarting server'
  command "kill -TERM `cat #{fetch(:deploy_to)}/shared/log/puma-#{fetch(:environment)}.pid` ; true"
end

desc 'Does local cleanup'
task :local_cleanup do
  sh 'rm -r vendor/cache'
  sh 'bundle config --local with ""'
  sh 'bundle config --local without ""'
end

task :staging do
  set :rails_env, 'staging'
  set :domain, 'linobis.acao.it'
  set :deploy_to, '/opt/acao-core'
  set :environment, 'staging'
end

task :production do
  set :rails_env, 'production'

  if `git branch --show-current`.chomp != 'production'
    abort 'Production deployment is supposed to be done from production branch'
  end

  set :domain, 'lino.acao.it'
  set :deploy_to, '/opt/acao-core'
  set :environment, 'production'
end

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    sh "bundle config --local with 'production hel_together puma'"
    sh 'bundle config --local without "development test"'
    sh 'bundle install --quiet'
    sh 'bundle package'

    sh "rsync --recursive --delete --delete-excluded #{fetch(:rsync_excludes)} . #{fetch(:domain)}:#{fetch(:deploy_to)}/upload"

    comment 'Moving upload to build path.'
    command "cp -r #{fetch(:deploy_to)}/upload/{.??,}* ."

    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'deploy:cleanup'
    invoke :local_cleanup

    on :launch do
      invoke :restart
    end
  end
end
