case Rails.env
when 'development'
  Rails.application.config.hosts << 'esophagus.test' # iPhone
when 'test'
  Rails.application.config.hosts << 'www.example.com'
  Rails.application.config.hosts << 'esophagus.test'
when 'production'
  Rails.application.config.hosts << 'esophagus.fly.dev'
end
