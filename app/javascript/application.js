// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails'
import 'controllers'
import 'trix'
import '@rails/actiontext'
import LocalTime from 'local-time'
LocalTime.start()
// TODO: Fix timezone detection - currently breaking Turbo
// import 'sprinkles/time_zone'
