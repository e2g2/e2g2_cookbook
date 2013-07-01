ENV['PATH'] = "#{node['postgresql']['dir']}/bin:#{ENV['PATH']}"
ENV['LD_LIBRARY_PATH'] = "#{node['postgresql']['dir']}/lib"

# install dependencies
%w(build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt1-dev libssl-dev).each do |pkg|
  package pkg
end

gem_package "ruby-shadow" do
  action :install
end

# download PostgreSQL
remote_file "/usr/local/src/postgresql-#{node['postgresql']['version']}.tar.gz" do
  source "http://ftp.postgresql.org/pub/source/v#{node['postgresql']['version']}/postgresql-#{node['postgresql']['version']}.tar.gz"
  mode "0644"
  action :create_if_missing
end

# install PostgreSQL
execute "install_postgresql_#{node['postgresql']['version']}" do
  user "root"
  command <<-EOH
    cd /usr/local/src && \
    tar xzvf postgresql-#{node['postgresql']['version']}.tar.gz && \
    cd postgresql-#{node['postgresql']['version']} && \
    ./configure --with-openssl --with-libxml --with-libxslt --prefix=#{node['postgresql']['dir']} && \
    make && make install && \
    cd contrib && \
    make && make install && \
    rm -rf /usr/local/src/postgresql-#{node['postgresql']['version']}/ && \
    echo "PATH=#{node['postgresql']['dir']}/bin:$PATH > /etc/environment && \
    echo "LD_LIBRARY_PATH=#{node['postgresql']['dir']}/lib" >> /etc/environment && \
    source /etc/environment
  EOH

  creates "#{node['postgresql']['dir']}/bin/initdb"
  action :run
end

# add postgres user
user "postgres" do
  shell "/bin/bash"
  system true
  password "$1$ZzqXiSIu$5xTLN7Q6DJn2lLVKoBd1Y1"
  action :create
end

# add postgres data dir
directory "#{node['postgresql']['data_dir']}" do
  owner "postgres"
  group "postgres"
  mode "0700"
  recursive true
  action :create
end

execute "setup postgres directory permissions" do
  command "chown -Rf postgres:postgres #{node['postgresql']['dir']}"
  only_if { Etc.getpwuid(File.stat(node['postgresql']['dir']).uid).name != "postgres" }
end

# initdb
execute "init_postgresql_db" do
  user "postgres"
  command "#{node['postgresql']['dir']}/bin/initdb -D #{node['postgresql']['data_dir']}"
  creates "#{node['postgresql']['data_dir']}/PG_VERSION"
  action :run
end

template "/etc/init.d/postgres" do
  source "postgres.initd.erb"
  mode "0755"
  owner "root"
  group "root"

  variables(
    postgresql_dir: node['postgresql']['dir'],
    postgresql_data_dir: node['postgresql']['data_dir']
  )

  notifies :restart, "service[postgres]"
end

template "#{node['postgresql']['data_dir']}/postgresql.conf" do
  source "postgresql.conf.erb"
  mode "0755"
  owner "postgres"
  group "postgres"

  notifies :restart, "service[postgres]"
end

service "postgres" do
  supports status: true, restart: true, reload: true, start: true, stop: true
  action [:enable, :start]
end
