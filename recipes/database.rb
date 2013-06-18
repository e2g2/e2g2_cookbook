include_recipe 'postgresql::server'
include_recipe 'postgresql::server_dev'
include_recipe 'postgresql::contrib'
include_recipe 'e2g2::postgis'

%w(development).each do |dbenv|
  # create user
  pg_user 'e2g2' do
    priveleges superuser: true, createdb: true, login: true
    encrypted_password 'b6bf3f456a67612cfe86e5e85c7f393d'
  end

  # create database
  pg_database "e2g2_#{dbenv}" do
    owner 'e2g2'
    encoding 'utf8'
    template 'template0'
    locale 'en_US.UTF8'
  end

  # enable extensions
  pg_database_extensions "e2g2_#{dbenv}" do
    extensions %w(address_standardizer citext fuzzystrmatch hstore pg_trgm postgis postgis_tiger_geocoder postgis_topology unaccent)
  end

  # enable datbase to access postgis extensions
  %w(geometry_columns geography_columns spatial_ref_sys).each do |table|
    execute "psql -c 'GRANT ALL ON #{table} TO PUBLIC' e2g2_#{dbenv}" do
      user "postgres"
    end
  end
  %w(tiger topology).each do |schema|
    execute "psql -c 'GRANT ALL ON SCHEMA #{schema} TO PUBLIC' e2g2_#{dbenv}" do
      user "postgres"
    end
  end
end
