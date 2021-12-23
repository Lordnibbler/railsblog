const { environment } = require('@rails/webpacker')
const jquery = require('./plugins/jquery')

environment.plugins.prepend('jquery', jquery)

const videoLoader = {
  test: /\.(webm|mp4)$/i,
  use: [{
    loader: 'file-loader',
    options: {
      name: '[path][name]-[hash].[ext]',
    }
  }]
}
environment.loaders.prepend('video', videoLoader)

// Get the actual sass-loader config
const sassLoader = environment.loaders.get('sass')
const sassLoaderConfig = sassLoader.use.find(function (element) {
return element.loader == 'sass-loader'
})

// Use Dart-implementation of Sass (default is node-sass)
const options = sassLoaderConfig.options
options.implementation = require('sass')

function hotfixPostcssLoaderConfig (subloader) {
  const subloaderName = subloader.loader
  if (subloaderName === 'postcss-loader') {
    subloader.options.postcssOptions = subloader.options.config
    delete subloader.options.config
  }
}

environment.loaders.keys().forEach(loaderName => {
  const loader = environment.loaders.get(loaderName)
  loader.use.forEach(hotfixPostcssLoaderConfig)
})

module.exports = environment
