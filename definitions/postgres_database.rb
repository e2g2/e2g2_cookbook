define :postgres_database, action: :create, user: 'postgres', encoding: 'utf8', owner: 'postgres', locale: 'en_US.UTF8', template: 'template0' do
  exists  = "psql -c \"SELECT datname from pg_database WHERE datname='#{params[:name]}'\""

  case params[:action].to_sym
  when :create
    execute "creating postgres database #{params[:name]}" do
      user params[:user]
      command "createdb -U #{params[:user]} -E #{params[:encoding]} -O #{params[:owner]} -l #{params[:locale]} -T #{params[:template]} #{params[:name]}"
      not_if exists, user: params[:user]
    end

    Array(params[:languages]).each do |language|
      execute "createlang #{language} #{params[:name]}" do
        user params[:user]
        not_if "psql -c 'SELECT lanname FROM pg_catalog.pg_language' #{params[:name]} | grep '^ #{language}$'", user: params[:user]
      end
    end

    Array(params[:extensions]).each do |extension|
      execute "psql -c 'CREATE EXTENSION IF NOT EXISTS #{extension}' #{params[:name]}" do
        user params[:user]
      end
    end
  when :drop
    execute "dropping postgres database #{params[:name]}" do
      user params[:user]
      command "dropdb -U #{params[:user]} #{params[:name]}"
      only_if exists, user: params[:user]
    end
  end
end
