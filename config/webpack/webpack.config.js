const path = require('path');
const { generateWebpackConfig, merge } = require('shakapacker');
const baseWebpackConfig = generateWebpackConfig();
const TerserPlugin = require('terser-webpack-plugin');

const options = {
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
              context: path.resolve(__dirname, '../../app/javascript/images'), // Base directory for images
              outputPath: 'images/',
              publicPath: '/packs/images/',
            },
          },
          {
            loader: 'image-webpack-loader',
            options: {
              mozjpeg: {
                progressive: true,
                quality: 65,
              },
              // other options...
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
              context: path.resolve(__dirname, '../../app/javascript/videos'), // Base directory for videos
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
    ],
  },
  optimization: {
    usedExports: true,
    splitChunks: {
      chunks: 'all',
    },
    minimize: true,
    minimizer: [new TerserPlugin()],
  },
  plugins: [
    // other plugins...
  ],
  mode: process.env.NODE_ENV === 'production' ? 'production' : 'development',
};

module.exports = merge({}, baseWebpackConfig, options);