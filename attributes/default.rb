# app configuration
default['app']['name']              = "e2g2"
default['app']['user']              = "deploy"
default['app']['user_password']     = "$1$eLsK0ABE$fP/kPLaaqhKaRj8.5lXBL0"
default['app']['server_name']       = "e2g2.com www.e2g2.com .e2g2.com .e2g2.dev"
default['app']['working_directory'] = "/home/deploy/e2g2"
default['app']['rails_env']         = "development"

# monit
default['monit']['password']        = "secret"

# package versions
default['gdal']['version']          = '1.10.0'
default['geos']['version']          = '20130724'
default['nginx']['version']         = '1.5.2'
default['postgis']['version']       = '2.1.0rc1'
default['postgresql']['version']    = '9.3beta2'
default['ruby']['version']          = '2.0.0-p247'
