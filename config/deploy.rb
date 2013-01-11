require "bundler/capistrano"
require "rvm/capistrano"

set :application, "midway"
set :group, "appserver"
set :scm, :git
set :repository, "git@github.com:mitadmin/#{application}.git"

set :rails_env, "production"
set :server_type, :passenger

# Amazon Server
# ec2-176-34-198-139.eu-west-1.compute.amazonaws.com
set :servers, '176.34.198.139'

role :web, servers
role :app, servers
role :db,  servers, :primary => true

set :deploy_to, "/opt/railsapps/applications/#{application}"
set :deploy_via, :remote_cache
set :ssh_options, {:forward_agent => true}

set :rvm_ruby_string, '1.9.3'
set :rvm_type, :system

default_run_options[:pty] = true

namespace :passenger do
  desc "Restart Passenger"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

after 'deploy:update_code' do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "rm #{release_path}/.rvmrc"
  run "cd #{release_path}; RAILS_ENV=production rake assets:precompile"
end

