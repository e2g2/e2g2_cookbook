package "redis-server"
gem_package "sidekiq" do
  version "~> 2.13.0"
end

template "#{node['app']['working_directory']}/current/config/sidekiq.yml" do
  source "sidekiq.yml.erb"
end

template "/etc/monit/conf.d/sidekiq.conf" do
  source "sidekiq.monit.erb"
  notifies :reload, "service[monit]"
end
