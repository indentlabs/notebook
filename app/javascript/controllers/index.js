import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
import Dropdown from 'stimulus-dropdown'

const application = Application.start()
application.register('dropdown', Dropdown)

const context = require.context(".", true, /\.js$/)
application.load(definitionsFromContext(context))