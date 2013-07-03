include_recipe "e2g2::nginx"
execute "cd #{node['app']['working_directory']}/current && bundle install --binstubs --path vendor/bundle"
