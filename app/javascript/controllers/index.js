import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

// import Dropdown from 'stimulus-dropdown'
import AnimatedNumber from 'stimulus-animated-number'

const application = Application.start()
// application.register('dropdown', Dropdown)
application.register('animated-number', AnimatedNumber)

const context = require.context(".", true, /\.js$/)
application.load(definitionsFromContext(context))