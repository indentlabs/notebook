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

// Remove Webpacker's CSS minifier entirely.
// cssnano v4 (bundled) recursively removes spaces in empty variables (like `--tw-gradient-from-position: ;` -> `tw-gradient-from-position:;`)
// which causes modern CSS engines to invalidate the entire declaration, breaking Tailwind v3 gradients completely.
// The plugin is only registered for production builds; deleting a missing item
// throws and breaks development/test compilation, so guard the delete.
if (environment.plugins.getIndex('OptimizeCSSAssets') >= 0) {
  environment.plugins.delete('OptimizeCSSAssets')
}

// This file is shared by all three environments, so guard production-only tweaks
// on NODE_ENV (config/webpack/production.js sets it before requiring us).
if (process.env.NODE_ENV === 'production') {
  // Webpacker defaults to `devtool: 'source-map'`, which appends a
  // `//# sourceMappingURL=` comment to every shipped bundle. Nothing consumes those
  // maps automatically (there is no browser-side Sentry SDK), but every visitor who
  // opens devtools pulls down a multi-megabyte map. `hidden-source-map` still writes
  // the maps into public/packs for manual debugging, just without the comment.
  environment.config.merge({ devtool: 'hidden-source-map' })

  // Webpacker gzips and brotlis `.map` files too, which is where most of the
  // "asset size limit" warnings in the precompile output come from. Maps are never
  // fetched with content-encoding negotiation, so drop them from both passes.
  const COMPRESSED_TYPES = /\.(js|css|html|json|ico|svg|eot|otf|ttf)$/
  const compressionPlugins = ['Compression', 'Compression Brotli']
  compressionPlugins.forEach((name) => {
    if (environment.plugins.getIndex(name) < 0) return
    const plugin = environment.plugins.get(name)
    if (plugin && plugin.options) plugin.options.test = COMPRESSED_TYPES
  })
}

module.exports = environment
