const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

// Fix postcss-loader v4 compatibility
const getCSSModuleLoader = (environment) => {
  const cssLoader = environment.loaders.get('moduleCss') || environment.loaders.get('css')
  if (!cssLoader) return null
  return cssLoader.use.find(el => el.loader === 'postcss-loader')
}

// Update postcss-loader options for v4 compatibility
const postcssLoader = getCSSModuleLoader(environment)
if (postcssLoader) {
  postcssLoader.options = {
    postcssOptions: {
      config: postcssLoader.options?.config?.path || './postcss.config.js'
    }
  }
}

// Apply the same fix to all style loaders
const updatePostcssLoaderOptions = (loader) => {
  if (loader && loader.use) {
    const postcssLoaderUse = loader.use.find(item =>
      item && (item.loader === 'postcss-loader' || item.loader?.includes('postcss-loader'))
    )
    if (postcssLoaderUse && postcssLoaderUse.options?.config) {
      const configPath = postcssLoaderUse.options.config.path || './postcss.config.js'
      postcssLoaderUse.options = {
        postcssOptions: {
          config: configPath
        }
      }
    }
  }
}

['css', 'moduleCss', 'sass', 'moduleSass'].forEach(loaderName => {
  try {
    const loader = environment.loaders.get(loaderName)
    updatePostcssLoaderOptions(loader)
  } catch (e) {
    // Loader not found, skip
  }
})

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
