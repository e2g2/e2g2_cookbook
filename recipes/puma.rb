gem_package "puma" do
  version "~> 2.4.0"
end

template "#{node['app']['working_directory']}/current/config/puma.rb" do
  source "puma.rb.erb"
end

template "/etc/monit/conf.d/puma.conf" do
  source "puma.monit.erb"
  notifies :reload, "service[monit]"
end
