define :gem_install do
  execute "gem install #{params[:name]} --no-ri --no-rdoc" do
    not_if { `gem list #{params[:name]}`.lines.grep(/^#{params[:name]} \(.*\)/)}
  end
end
