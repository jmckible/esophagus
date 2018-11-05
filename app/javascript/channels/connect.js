import ActionCable from 'actioncable'

(function() {
  if (!window.App) { window.App = {} }
  App.cable = ActionCable.createConsumer(document.querySelector('meta[name=action-cable-url]').getAttribute('content'))
}).call(this)
