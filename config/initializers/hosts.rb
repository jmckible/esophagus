case Rails.env
when 'development'
  Rails.application.config.hosts << 'esophagus.test'
end
