# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "local-time", to: "local-time.es2017-esm.js"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "jstz", to: "https://cdn.jsdelivr.net/npm/jstz@2.1.1/dist/jstz.min.js"
pin "js-cookie", to: "https://cdn.jsdelivr.net/npm/js-cookie@3.0.5/dist/js.cookie.min.mjs"
pin_all_from "app/javascript/sprinkles", under: "sprinkles"
