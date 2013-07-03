gem_install 'bluepill'
directory "/var/bluepill" do
  user node['app']['user']
  group node['app']['user']
end
