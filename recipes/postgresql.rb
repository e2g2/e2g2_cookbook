ENV['PATH'] = "/usr/local/pgsql/bin:#{ENV['PATH']}"
ENV['LD_LIBRARY_PATH'] = "/usr/local/pgsql/lib"

# install dependencies
gem_package "ruby-shadow"
%w(build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt1-dev libssl-dev).each do |pkg|
  package pkg
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
    ./configure --with-openssl --with-libxml --with-libxslt --prefix=/usr/local/pgsql && \
    make && make install && \
    cd contrib && \
    make && make install && \
    rm -rf /usr/local/src/postgresql-#{node['postgresql']['version']}/ && \
    echo "PATH=/usr/local/pgsql/bin:$PATH > /etc/environment && \
    echo "LD_LIBRARY_PATH=/usr/local/pgsql/lib" >> /etc/environment && \
    source /etc/environment
  EOH

  creates "/usr/local/pgsql/bin/initdb"
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
directory "/usr/local/pgsql/data" do
  owner "postgres"
  group "postgres"
  mode "0700"
  recursive true
  action :create
end

execute "setup postgres directory permissions" do
  command "chown -Rf postgres:postgres /usr/local/pgsql"
  only_if { Etc.getpwuid(File.stat("/usr/local/pgsql").uid).name != "postgres" }
end

# initdb
execute "init_postgresql_db" do
  user "postgres"
  command "/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data"
  creates "/usr/local/pgsql/data/PG_VERSION"
  action :run
end

template "/etc/init.d/postgres" do
  source "postgres.init.erb"
  mode "0755"
  owner "root"
  group "root"
end

service "postgres" do
  supports status: true, restart: true, reload: true, start: true, stop: true
  action [:enable, :restart]
end

template "/usr/local/pgsql/data/postgresql.conf" do
  source "postgresql.conf.erb"
  mode "0755"
  owner "postgres"
  group "postgres"

  notifies :reload, "service[postgres]"
end
