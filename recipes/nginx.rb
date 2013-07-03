package 'libpcre3-dev'

remote_file "/usr/local/src/nginx-#{node['nginx']['version']}.tar.gz" do
  source "http://nginx.org/download/nginx-#{node['nginx']['version']}.tar.gz"
  mode "0644"
  action :create_if_missing
end

bash "install_nginx_#{node['nginx']['version']}" do
  user "root"
  code <<-EOH
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

template "/usr/local/nginx/conf/nginx.conf" do
  source "nginx.conf.erb"
  mode "0755"
  owner "root"
  group "root"

  # notifies :restart, "service[nginx]"
end

# service "nginx" do
#   supports status: true, restart: true, reload: true, start: true, stop: true
#   action [:enable, :start]
# end