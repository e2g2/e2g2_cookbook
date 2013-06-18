define :postgres_user, action: :create, user: 'postgres', privileges: {} do
  privileges      = {superuser: false, createdb: false, login: false}.merge(params[:privileges])
  exists          = "psql -c \"SELECT usename FROM pg_user WHERE usename='#{params[:name]}'\" | grep #{params[:name]}"
  privileges_cmd  = privileges.collect {|priv, grant| (grant ? priv : "NO#{priv}").upcase }.join(' ')

  case params[:action].to_sym
  when :create
    execute "create postgres user #{params[:name]}" do
      user params[:user]
      command "psql -c \"CREATE ROLE #{params[:name]} WITH ENCRYPTED PASSWORD '#{params[:password]}' #{privileges_cmd}\""
      not_if exists, user: params[:user]
    end

    execute "alter postgres user #{params[:name]}" do
      user params[:user]
      command "psql -c \"ALTER ROLE #{params[:name]} WITH ENCRYPTED PASSWORD '#{params[:password]}' #{privileges_cmd}\""
      only_if exists, user: params[:user]
    end
  when :drop
    execute "dropping pg user #{params[:name]}" do
      user params[:user]
      command "psql -c \"DROP ROLE IF EXISTS #{params[:name]}\""
    end
  end
end
