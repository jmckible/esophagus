namespace :database do

  task :restore_from_production do
    sh 'heroku pg:backups:download'
    sh 'pg_restore --verbose --clean --no-acl --no-owner -h localhost -d cook_development latest.dump'
    sh 'rm latest.dump*'
  end

end
