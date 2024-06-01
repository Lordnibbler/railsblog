const path = require('path');
const TerserPlugin = require('terser-webpack-plugin');

// Use the asset pipeline for images and other static assets.
// This file configures Webpack to output js, css, images, videos to a directory that the asset pipeline can serve
// That directory is app/assets/builds
module.exports = {
  entry: './app/javascript/packs/application.js',
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, './app/assets/builds'),
  },
  module: {
    rules: [
      {
        test: require.resolve('jquery'),
        loader: 'expose-loader',
        options: {
          exposes: ['$', 'jQuery']
        }
      },
      {
        test: /\.(png|jpe?g|gif|svg)$/i,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: "[path][name].[ext]",
              context: path.resolve(__dirname, './app/javascript/images'),
              outputPath: 'images/',
              publicPath: '/packs/images/',
            },
          },
        ],
      },
      {
        test: /\.mp4$/i,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: "[path][name].[ext]",
              context: path.resolve(__dirname, './app/javascript/videos'),
              outputPath: 'videos/',
              publicPath: '/packs/videos/',
            },
          },
        ],
      },
      {
        test: /\.module\.s(a|c)ss$/i,
        use: [
          "style-loader",
          "css-loader",
          "postcss-loader",
          {
            loader: "sass-loader",
            options: {
              implementation: require("sass"),
            },
          },
        ],
      },
      {
        test: /\.css$/i,
        use: [
          "style-loader",
          "css-loader",
          "postcss-loader",
        ],
      },
      {
        test: /\.s[ac]ss$/i,
        use: [
          "style-loader",
          "css-loader",
          "postcss-loader",
          "sass-loader",
        ],
      },
    ],
  },
  optimization: {
    usedExports: true,
    splitChunks: {
      chunks: 'all',
      name: false, // Disable the default name generation
      cacheGroups: {
        default: {
          minChunks: 2,
          priority: -20,
          reuseExistingChunk: true,
          filename: 'common.js', // Custom filename for common chunks
        },
        vendors: {
          test: /[\\/]node_modules[\\/]/,
          priority: -10,
          filename: 'vendors.js', // Custom filename for vendor chunks
        },
      },
    },
    minimize: true,
    minimizer: [new TerserPlugin()],
  },
  mode: process.env.NODE_ENV === 'production' ? 'production' : 'development',
};