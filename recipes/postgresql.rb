# install dependencies
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
bash "install_postgresql_#{node['postgresql']['version']}" do
  user "root"
  code <<-EOH
    cd /usr/local/src && \
    tar xzvf postgresql-#{node['postgresql']['version']}.tar.gz && \
    cd postgresql-#{node['postgresql']['version']} && \
    ./configure --with-openssl --with-libxml --with-libxslt --prefix=#{node['postgresql']['dir']} && \
    make && make install && \
    rm -rf /usr/local/src/postgresql-#{node['postgresql']['version']}/
  EOH

  creates "/usr/local/#{node['postgresql']['version']}/bin/initdb"
  action :run
end
