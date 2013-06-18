include_recipe 'postgresql::server'
include_recipe 'postgresql::server_dev'
include_recipe 'postgresql::contrib'
include_recipe 'e2g2::postgis'

# create user
postgres_user 'e2g2' do
  privileges superuser: true, createdb: true, login: true
  password 'b6bf3f456a67612cfe86e5e85c7f393d'
end

# create databases
%w(development).each do |dbenv|
  postgres_database "e2g2_#{dbenv}" do
    owner 'e2g2'
    extensions %w(address_standardizer citext fuzzystrmatch hstore pg_trgm postgis postgis_tiger_geocoder postgis_topology unaccent)
  end
end
