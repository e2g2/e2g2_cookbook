# install dependencies
%w(libxml2-dev proj libjson0-dev xsltproc docbook-xsl gettext).each do |pkg|
  package pkg
end

# download GDAL
remote_file "/usr/local/src/gdal-#{node['gdal']['version']}.tar.gz" do
  source "http://download.osgeo.org/gdal/gdal-#{node['gdal']['version']}.tar.gz"
  mode "0644"
  action :create_if_missing
end

# install GDAL
bash "install_gdal_#{node['gdal']['version']}" do
  user "root"
  code <<-EOH
    cd /usr/local/src && \
    tar xzvf gdal-#{node['gdal']['version']}.tar.gz && \
    cd gdal-#{node['gdal']['version']} && \
    ./configure && make && make install && ldconfig && \
    cd /usr/local/src && rm -rf gdal-#{node['gdal']['version']}/
  EOH

  creates "/usr/local/bin/gdal-config"
  action :run
end

# download GEOS
remote_file "/usr/local/src/geos-#{node['geos']['version']}.tar.bz2" do
  source "http://download.osgeo.org/geos/geos-#{node['geos']['version']}.tar.bz2"
  mode "0644"
  action :create_if_missing
end

# install GEOS
bash "install_geos_#{node['geos']['version']}" do
  user "root"
  code <<-EOH
    cd /usr/local/src && \
    bunzip2 -f geos-#{node['geos']['version']}.tar.bz2 && \
    tar xvf geos-#{node['geos']['version']}.tar && \
    cd geos-#{node['geos']['version']} && \
    ./configure && make && make install && ldconfig && \
    cd /usr/local/src && rm -rf geos-#{node['geos']['version']}/
  EOH

  creates "/usr/local/bin/geos-config"
  action :run
end

# download PostGIS
remote_file "/usr/local/src/postgis-#{node['postgis']['version']}.tar.gz" do
  source "http://download.osgeo.org/postgis/source/postgis-#{node['postgis']['version']}.tar.gz"
  mode "0644"
  action :create_if_missing
end

# install PostGIS
bash "install_postgis_#{node['postgis']['version']}" do
  user "root"
  code <<-EOH
    cd /usr/local/src && \
    tar xzvf postgis-#{node['postgis']['version']}.tar.gz && \
    cd postgis-#{node['postgis']['version']} && \
    ./configure && make && make install && ldconfig && \
    cd /usr/local/src && rm -rf postgis-#{node['postgis']['version']}/
  EOH

  creates "/usr/share/postgresql/9.2/extension/postgis--#{node['postgis']['version']}.sql"
  action :run
end
