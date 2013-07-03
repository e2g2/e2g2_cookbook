ENV['PATH'] = "./bin:/usr/local/pgsql/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/chef/embedded/bin"
ENV['LD_LIBRARY_PATH'] = "/usr/local/pgsql/lib"

bash "set_environment_variables" do
  user "root"
  command <<-EOH
    echo "PATH=#{ENV['PATH']}\nLD_LIBRARY_PATH=#{ENV['LD_LIBRARY_PATH']}" > /etc/environment &&
    source /etc/environment
  EOH
end

include_recipe 'apt'
include_recipe 'e2g2::ruby'
include_recipe 'e2g2::bluepill'
include_recipe 'e2g2::database'
include_recipe 'e2g2::web'
