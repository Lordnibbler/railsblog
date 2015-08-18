// sets up the JS and CSS assets for the Webpack Dev Server
// Run like this:
// cd client && node server.js

const path = require('path');
const config = require('./webpack.common.config');
const webpack = require('webpack');

config.entry.push(
  'webpack-dev-server/client?http://localhost:3000',
  'webpack/hot/dev-server',
  './scripts/webpack_only'
);

config.output = {
  // this file is served directly by webpack
  filename: 'express-bundle.js',
  path: __dirname,
};

config.plugins = [new webpack.HotModuleReplacementPlugin()];
config.devtool = 'eval-source-map';

// Add the styles
config.resolve.root.push(
  path.join(__dirname, 'assets/stylesheets'),
  path.join(__dirname, '../app/assets/stylesheets')
);

// allow .sass, .scss files to use globbed imports like `@import "foo/**/*";`
config.module.preLoaders = [{
  test: /\.scss$|\.sass$/,
  loader: 'import-glob-loader'
}];

// All the styling loaders only apply to hot-reload, not rails
config.module.loaders.push(
  { test: /\.jsx?$/, loaders: ['react-hot', 'babel'], exclude: /node_modules/ },
  { test: /\.css$/, loader: 'style-loader!css-loader' },

  {
    test: /\.scss$|\.sass$/,
    // pass indentedSyntax query param to node-sass for .sass file support
    loader: 'style!css!sass?indentedSyntax&outputStyle=expanded&imagePath=/assets/images&'  +
    'includePaths[]=' + encodeURIComponent(path.resolve(__dirname, './assets/stylesheets')) + '&' +
    'includePaths[]=' + encodeURIComponent(path.resolve(__dirname, '../app/assets/stylesheets')) + '&' +
    'includePaths[]=' + encodeURIComponent(path.resolve(__dirname, '../vendor/assets/stylesheets')) + '&' +
    'includePaths[]=' + encodeURIComponent(path.resolve(__dirname, '../vendor/assets/bower_components'))
  },

  // The url-loader uses DataUrls. The file-loader emits files.
  { test: /\.woff$/, loader: 'url-loader?limit=10000&minetype=application/font-woff' },
  { test: /\.woff2$/, loader: 'url-loader?limit=10000&minetype=application/font-woff' },
  { test: /\.ttf$/, loader: 'file-loader' },
  { test: /\.eot$/, loader: 'file-loader' },
  { test: /\.svg$/, loader: 'file-loader' }
);

module.exports = config;
