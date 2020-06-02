require 'mina/rails'

set :application_name, 'acao-core'
set :user, 'yggdra'
set :domain, 'linobis.acao.it'
set :production_domain, 'lino.acao.it'
set :deploy_to, '/opt/acao-core'
set :shared_dirs, fetch(:shared_dirs, []) + [ ]
set :shared_files, fetch(:shared_files, []) + [ 'config/database.yml', 'config/secrets.yml', ]
set :repository, 'foobar'
set :keep_releases, 20
set :rails_env, 'staging'
set :rsync_excludes, [
  '.git*',
  '/config/database.yml',
  '/config/secrets.yml',
  '/vendor/bundle',
  '/tmp/cache',
  '/log',
].map { |x| "--exclude \"#{x}\"" }.join(' ')

task :environment do
end

task :setup do
  command %[touch "#{fetch(:deploy_to)}/shared/config/database.yml"]
  comment "Be sure to edit 'shared/config/database.yml'."

  command %[touch "#{fetch(:deploy_to)}/shared/config/secrets.yml"]
  comment "Be sure to edit 'shared/config/secrets.yml'."
end

task :restart do
  comment 'Restarting server'
  command "kill -TERM `cat #{fetch(:deploy_to)}/shared/log/puma-staging.pid` ; true"
  command "kill -TERM `cat #{fetch(:deploy_to)}/shared/log/puma-production.pid` ; true"
end

desc 'Does local cleanup'
task :local_cleanup do
  sh 'rm -r vendor/cache'
  sh 'bundle install --without ""'
end

task :production do
  set :domain, fetch(:production_domain)
  set :rails_env, 'production'
end

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    sh 'bundle install --quiet --without "development test"'
    #sh 'bundle package --all'
    sh 'bundle package'

    sh "rsync --recursive --delete --delete-excluded #{fetch(:rsync_excludes)} . #{fetch(:domain)}:#{fetch(:deploy_to)}/upload"

    comment 'Moving upload to build path.'
    command "cp -r #{fetch(:deploy_to)}/upload/{.??,}* ."

    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
#    invoke :'db:porn:migrate'
    invoke :'deploy:cleanup'
    invoke :local_cleanup

    on :launch do
      invoke :restart
    end
  end
end
