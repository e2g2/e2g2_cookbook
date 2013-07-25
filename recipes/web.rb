include_recipe "e2g2::nginx"
include_recipe "e2g2::puma"

# install gem dependencies
package 'libsqlite3-dev'
package 'nodejs'

# install gems
bash "cd #{node['app']['working_directory']}/current && bundle install --binstubs --path vendor/bundle"
