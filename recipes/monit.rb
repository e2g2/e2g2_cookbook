package 'monit'

service "monit" do
  supports restart: true, reload: true, start: true, stop: true
  action [:enable, :restart]
end

template "/etc/monit/monitrc" do
  source "monitrc.erb"
  mode "0400"
  owner "root"
  group "root"
  notifies :reload, "service[monit]"
end

bash "update-rc.d monit defaults"
