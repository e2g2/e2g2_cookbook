include_recipe "e2g2::nginx"
bash "cd #{node['app']['working_directory']}/current && bundle install --binstubs --path vendor/bundle"
