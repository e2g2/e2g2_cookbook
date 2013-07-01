package 'libreadline-dev'
package 'libssl-dev'
package 'libyaml-0-2'

remote_file "/usr/local/src/ruby-#{node['ruby']['version']}.tar.gz" do
  source "http://ftp.ruby-lang.org/pub/ruby/ruby-#{node['ruby']['version']}.tar.gz"
  mode "0644"
  action :create_if_missing
end

bash "install_ruby_#{node['ruby']['version']}" do
  user "root"
  code <<-EOH
    cd /usr/local/src &&
    tar xzvf ruby-#{node['ruby']['version']}.tar.gz &&
    cd /usr/local/src/ruby-#{node['ruby']['version']} &&
    ./configure &&
    make && make install &&
    rm -rf /usr/local/src/ruby-#{node['ruby']['version']}
  EOH

  creates "/usr/local/bin/ruby"
  action :run
end
