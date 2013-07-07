gem_package "puma"

template "#{node['app']['working_directory']}/current/config/puma.rb" do
  source "puma.rb.erb"
end

template "/etc/monit/conf.d/puma.conf" do
  source "puma.monit.erb"
  notifies :reload, "service[monit]"
end
