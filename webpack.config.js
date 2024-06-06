const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const webpack = require('webpack');

module.exports = {
  entry: {
    application: './app/javascript/packs/application.js',
    active_admin: [
      './app/javascript/packs/active_admin.js',
      './app/javascript/packs/active_admin.scss'
    ]
  },
  output: {
    filename: (pathData) => {
      return pathData.chunk.name === 'active_admin' ? '../javascripts/[name].js' : '[name].js';
    },
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
        test: require.resolve('jquery-ui/ui/widget'),
        loader: 'expose-loader',
        options: {
          exposes: ['$.widget']
        }
      },
      {
        test: require.resolve('jquery-ui/ui/widgets/datepicker'),
        loader: 'expose-loader',
        options: {
          exposes: ['$.ui.datepicker']
        }
      },
      {
        test: require.resolve('jquery-ui/ui/widgets/dialog'),
        loader: 'expose-loader',
        options: {
          exposes: ['$.ui.dialog']
        }
      },
      {
        test: require.resolve('jquery-ui/ui/widgets/sortable'),
        loader: 'expose-loader',
        options: {
          exposes: ['$.ui.sortable']
        }
      },
      {
        test: require.resolve('jquery-ui/ui/widgets/tabs'),
        loader: 'expose-loader',
        options: {
          exposes: ['$.ui.tabs']
        }
      },
      {
        test: /\.(png|jpe?g|gif|svg|webp|bmp|tiff)$/i,
        type: 'asset/resource',
        generator: {
          filename: (pathData) => {
            const relativePath = path.relative(path.resolve(__dirname, 'app/javascript'), pathData.filename);
            return `images/${relativePath.replace(/^images\//, '')}`;
          },
        },
      },
      {
        test: /\.mp4$/i,
        type: 'asset/resource',
        generator: {
          filename: (pathData) => {
            const relativePath = path.relative(path.resolve(__dirname, 'app/javascript'), pathData.filename);
            return `videos/${relativePath.replace(/^videos\//, '')}`;
          },
        },
      },
      {
        test: /\.css$/i,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'postcss-loader',
        ],
      },
      {
        test: /\.s[ac]ss$/i,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'postcss-loader',
          'sass-loader'
        ],
      },
    ],
  },
  optimization: {
    usedExports: true,
    minimize: true,
    minimizer: [new TerserPlugin()],
  },
  plugins: [
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      'window.jQuery': 'jquery',
    }),
    new MiniCssExtractPlugin({
      filename: (pathData) => {
        return pathData.chunk.name === 'active_admin' ? '../stylesheets/[name].css' : '[name].css';
      },
    }),
  ],
  mode: process.env.NODE_ENV === 'production' ? 'production' : 'development',
  resolve: {
    alias: {
      images: path.resolve(__dirname, 'app/javascript/images'),
    },
  },
};
