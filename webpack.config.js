const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');

module.exports = {
  entry: './app/javascript/packs/application.js',
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'public/packs'),
    publicPath: '/packs/',
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
        test: /\.(png|jpe?g|gif|svg|webp|bmp|tiff)$/i,
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
        test: /\.css$/i,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'postcss-loader',
        ],
      },
      // {
      //   test: /\.s[ac]ss$/i,
      //   use: [
      //     MiniCssExtractPlugin.loader,
      //     'css-loader',
      //     'postcss-loader',
      //     'sass-loader',
      //   ],
      // },
      // {
      //   test: /\.sass$/,
      //   use: [
      //     'style-loader',
      //     'css-loader',
      //     {
      //       loader: 'sass-loader',
      //       options: {
      //         sassOptions: {
      //           indentedSyntax: true, // using indented syntax for .sass files
      //         },
      //       },
      //     },
      //   ],
      // },

      // {
      //   test: /\.s[ac]ss$/i,
      //   use: [
      //     'style-loader',
      //     'css-loader',
      //     'sass-loader'
      //   ],
      // },

      {
        test: /\.s[ac]ss$/i,
        use: [
          'style-loader',
          'css-loader',
          {
            loader: 'postcss-loader',
            options: {
              postcssOptions: {
                plugins: [
                  require('autoprefixer')
                ],
              },
            },
          },
          'sass-loader'
        ],
      },
    ],
  },
  optimization: {
    usedExports: true,
    splitChunks: {
      chunks: 'all',
      name: false,
      cacheGroups: {
        default: {
          minChunks: 2,
          priority: -20,
          reuseExistingChunk: true,
          filename: 'common.js',
        },
        vendors: {
          test: /[\\/]node_modules[\\/]/,
          priority: -10,
          filename: 'vendors.js',
        },
      },
    },
    minimize: true,
    minimizer: [new TerserPlugin()],
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: '[name].css',
    }),
  ],
  mode: process.env.NODE_ENV === 'production' ? 'production' : 'development',
  resolve: {
    alias: {
      images: path.resolve(__dirname, 'public/packs/images'),
    },
  },
};
