set :application, "rpx_demo"
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :keep_releases, "5"

set :scm, :git
set :repository, "git@github.com:amitkssolanki/rpx_demo.git"
set :branch, "master"

set :user, 'amit'
set :use_sudo, true
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

role :app, "72.249.123.156"
role :web, "72.249.123.156"
role :db, "72.249.123.156", :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
  task :after_symlink, :roles => :app do
    run "cp #{shared_path}/database.yml #{current_path}/config/database.yml"
  end
  
  desc "Deploy with migrations"
  task :long do
    transaction do
      update_code
      web.disable
      symlink
      migrate
    end

    restart
    web.enable
    cleanup
  end
  
  desc "Run cleanup after long_deploy"
  task :after_deploy do
    cleanup
  end
  
end