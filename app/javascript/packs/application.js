/* eslint no-console:0 */

import Rails from 'rails-ujs'
Rails.start()

import Turbolinks from 'turbolinks'
Turbolinks.start()

import ActionCable from 'actioncable'
require('../channels/connect')

import * as ActiveStorage from 'activestorage'
ActiveStorage.start()

import 'actiontext'

import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'

const application = Application.start()
const context = require.context('controllers', true, /.js$/)
application.load(definitionsFromContext(context))
