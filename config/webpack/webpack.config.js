const path = require('path');
const { generateWebpackConfig, merge } = require('shakapacker');
const baseWebpackConfig = generateWebpackConfig();
const TerserPlugin = require('terser-webpack-plugin');

const options = {
  // entry: {
  //   application: './app/javascript/packs/application.js',
  //   // other entry points...
  // },
  // output: {
  //   path: path.resolve(__dirname, '../../public/packs'),
  //   filename: '[name].js',
  //   publicPath: '/packs/', // Ensure the public path is set correctly
  // },
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
        test: /\.(png|jpe?g|gif|svg|mp4)$/i,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: "[name].[ext]",
              outputPath: (url, resourcePath, context) => {
                if (/\.mp4$/.test(resourcePath)) {
                  return `video/${url}`;
                }
                return `images/${url}`;
              },
              publicPath: (url, resourcePath, context) => {
                if (/\.mp4$/.test(resourcePath)) {
                  return `/packs/video/${url}`;
                }
                return `/packs/images/${url}`;
              },
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