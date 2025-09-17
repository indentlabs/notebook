const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.config.merge({
  module: {
    rules: [
      {
        test: /\.mjs$/,
        include: /node_modules/,
        type: "javascript/auto"
      }
    ]
  }
})

// Ignore the optional react-dom/client import warning for React 16
environment.plugins.append('IgnorePlugin',
  new webpack.IgnorePlugin({
    resourceRegExp: /^react-dom\/client$/,
    contextRegExp: /react_ujs/
  })
)

// Configure sass-loader to suppress dependency warnings
const sassLoader = environment.loaders.get('sass')
const sassLoaderConfig = sassLoader.use.find(item => item.loader === 'sass-loader')
if (sassLoaderConfig) {
  sassLoaderConfig.options = {
    ...sassLoaderConfig.options,
    sassOptions: {
      ...sassLoaderConfig.options?.sassOptions,
      // Suppress deprecation warnings from node_modules
      quietDeps: true,
      // Silence specific deprecations we can't fix due to third-party deps
      silenceDeprecations: ['import', 'legacy-js-api']
    }
  }
}

module.exports = environment
