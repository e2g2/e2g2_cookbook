define :postgres_database, action: :create, user: 'postgres', encoding: 'utf8', owner: 'postgres', locale: 'en_US.UTF8', template: 'template0' do
  exists      = "psql -c \"SELECT datname from pg_database WHERE datname='#{params[:name]}'\" | grep #{params[:name]}"
  extensions  = Array(params[:extensions])
  languages   = Array(params[:languages])

  case params[:action].to_sym
  when :create
    #####################################
    # create database
    #####################################
    execute "creating postgres database #{params[:name]}" do
      user params[:user]
      command "createdb -U #{params[:user]} -E #{params[:encoding]} -O #{params[:owner]} -l #{params[:locale]} -T #{params[:template]} #{params[:name]}"
      not_if exists, user: params[:user]
    end

    #####################################
    # enable languages
    #####################################
    languages.each do |language|
      execute "createlang #{language} #{params[:name]}" do
        user params[:user]
        not_if "psql -c 'SELECT lanname FROM pg_catalog.pg_language' #{params[:name]} | grep '^ #{language}$'", user: params[:user]
      end
    end

    #####################################
    # install extension dependencies
    #####################################
    if extensions.include?('address_standardizer')
      package "libpcre3"
      package "libpcre3-dev"

      # download PAGC
      remote_file "/usr/local/src/pagc.tar.gz" do
        source "http://pagc.svn.sourceforge.net/viewvc/pagc/branches/sew-refactor/postgresql/?view=tar"
        mode "0644"
        action :create_if_missing
      end

      # install PAGC
      execute "install_pagc_postgresql" do
        user "root"
        command <<-EOH
          cd /usr/local/src &&
          tar xzvf pagc.tar.gz &&
          cd postgresql &&
          make && make install &&
          rm -rf /usr/local/src/postgresql/
        EOH

        creates "#{node['postgresql']['dir']}/postgresql/extension/address_standardizer--1.0.sql"
        action :run
      end
    end

    if extensions.include?('postgis')
      # install dependencies
      package 'libproj-dev'
      package 'libjson0-dev'
      package 'xsltproc'
      package 'docbook-xsl'
      package 'gettext'

      # download GDAL
      remote_file "/usr/local/src/gdal-#{node['gdal']['version']}.tar.gz" do
        source "http://download.osgeo.org/gdal/#{node['gdal']['version']}/gdal-#{node['gdal']['version']}.tar.gz"
        mode "0644"
        action :create_if_missing
      end

      # install GDAL
      execute "install_gdal_#{node['gdal']['version']}" do
        user "root"
        command <<-EOH
          cd /usr/local/src &&
          tar xzvf gdal-#{node['gdal']['version']}.tar.gz &&
          cd gdal-#{node['gdal']['version']} &&
          ./configure && make && make install && ldconfig &&
          rm -rf /usr/local/src/gdal-#{node['gdal']['version']}/
        EOH

        creates "/usr/local/bin/gdal-config"
        action :run
      end

      # download GEOS
      remote_file "/usr/local/src/geos-#{node['geos']['version']}.tar.bz2" do
        source "http://geos.osgeo.org/snapshots/geos-#{node['geos']['version']}.tar.bz2"
        mode "0644"
        action :create_if_missing
      end

      # install GEOS
      execute "install_geos_#{node['geos']['version']}" do
        user "root"
        command <<-EOH
          cd /usr/local/src &&
          bunzip2 -f geos-#{node['geos']['version']}.tar.bz2 &&
          tar xvf geos-#{node['geos']['version']}.tar &&
          cd geos-#{node['geos']['version']} &&
          ./configure && make && make install && ldconfig &&
          rm -rf /usr/local/src/geos-#{node['geos']['version']}/
        EOH

        creates "/usr/local/bin/geos-config"
        action :run
      end

      # download PostGIS
      remote_file "/usr/local/src/postgis-#{node['postgis']['version']}.tar.gz" do
        source "http://postgis.net/stuff/postgis-#{node['postgis']['version']}.tar.gz"
        mode "0644"
        action :create_if_missing
      end

      # install PostGIS
      execute "install_postgis_#{node['postgis']['version']}" do
        user "root"
        command <<-EOH
          cd /usr/local/src &&
          tar xzvf postgis-#{node['postgis']['version']}.tar.gz &&
          cd postgis-#{node['postgis']['version']} &&
          ./configure && make && make install && ldconfig &&
          rm -rf /usr/local/src/postgis-#{node['postgis']['version']}/
        EOH

        creates "#{node['postgresql']['dir']}/share/extension/postgis.control"
        action :run
      end
    end

    #####################################
    # enable extensions
    #####################################
    extensions.each do |extension|
      execute "psql -c 'CREATE EXTENSION IF NOT EXISTS #{extension}' #{params[:name]}" do
        user params[:user]
      end
    end
  when :drop
    execute "dropping postgres database #{params[:name]}" do
      user params[:user]
      command "dropdb -U #{params[:user]} #{params[:name]}"
      only_if exists, user: params[:user]
    end
  end
end
