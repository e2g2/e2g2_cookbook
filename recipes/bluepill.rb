gem_package 'bluepill'

directory "/var/bluepill" do
  user node['app']['user']
  group node['app']['user']
end

template "/etc/init/bluepill.conf" do
  source "bluepill.conf.erb"
  mode "0644"
  owner "root"
  group "root"
end

bash "start bluepill" do
  user "root"
end
