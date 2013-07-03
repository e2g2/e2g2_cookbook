package 'libpcre3-dev'

remote_file "/usr/local/src/nginx-#{node['nginx']['version']}.tar.gz" do
  source "http://nginx.org/download/nginx-#{node['nginx']['version']}.tar.gz"
  mode "0644"
  action :create_if_missing
end

user node['app']['user'] do
  shell "/bin/bash"
  home "/home/#{node['app']['user']}"
  password node['app']['user_password']
  supports manage_home: true
  action :create
end

%w(current releases shared/log shared/tmp/pids shared/tmp/sockets).each do |dir|
  directory "#{node['app']['working_directory']}/#{dir}" do
    owner node['app']['user']
    group node['app']['user']
    mode '0755'
    recursive true
  end
end

execute "install_nginx_#{node['nginx']['version']}" do
  user "root"
  command <<-EOH
    cd /usr/local/src &&
    tar xzvf nginx-#{node['nginx']['version']}.tar.gz &&
    cd /usr/local/src/nginx-#{node['nginx']['version']} &&
    ./configure &&
    make && make install &&
    rm -rf /usr/local/src/nginx-#{node['nginx']['version']}
  EOH

  creates "/usr/local/nginx"
  action :run
end

template "/etc/init.d/nginx" do
  source "nginx.init.erb"
  mode "0755"
  owner "root"
  group "root"
end

service "nginx" do
  supports status: true, restart: true, reload: true, start: true, stop: true
  action [:enable, :restart]
end

template "/usr/local/nginx/conf/nginx.conf" do
  source "nginx.conf.erb"
  mode "0755"
  owner "root"
  group "root"

  notifies :reload, "service[nginx]"
end
