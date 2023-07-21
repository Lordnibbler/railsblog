const path    = require("path")
const webpack = require("webpack")

// Extracts CSS into .css file
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
// Removes exported JavaScript files from CSS-only entries
// in this example, entry.custom will create a corresponding empty custom.js file
const RemoveEmptyScriptsPlugin = require('webpack-remove-empty-scripts');

const mode = process.env.NODE_ENV === 'development' ? 'development' : 'production';

module.exports = {
  mode,
  optimization: {
    moduleIds: 'deterministic',
  },
  entry: {
    // add your css or sass entries
    application: [
      './app/javascript/packs/application.js',
      './app/javascript/packs/application.css',
    ],
    // TODO: multiple packs are back lol
    // custom: './app/assets/stylesheets/custom.scss',
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    path: path.resolve(__dirname, '..', '..', 'app/assets/builds')
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    }),
    new RemoveEmptyScriptsPlugin(),
    new MiniCssExtractPlugin(),
  ],
  module : {
    rules: [
      {
        test: /\.(js)$/,
        exclude: /node_modules/,
        use: ['babel-loader'],
      },
      {
        test: require.resolve('jquery'),
        loader: 'expose-loader',
        options: {
          exposes: ['$', 'jQuery']
        }
      },
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg|mp4)$/i,
        use: [{
          loader: "file-loader",
          options: {
            name(resourcePath, resourceQuery) {
              // `resourcePath` - `/absolute/path/to/file.js`
              // `resourceQuery` - `?foo=bar`
              // TODO: this might be wrong/unnecessary; without this the default is `[contenthash].[ext] and
              // we can't reference asset like image_tag("foo.jpg")
              if (process.env.NODE_ENV === 'development') {
                return '[name].[ext]';
              }

              return '[contenthash].[ext]';
            },
          }
        }]
      },

      // {
      //   test: /\.mp4$/,
      //   use: [{
      //     loader: "file-loader",
      //     options: {
      //       name: "[name].[ext]",
      //       outputPath: "video"
      //     }
      //   }]
      // },
      // {
      //   test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
      //   use: 'file-loader',
      // },
      // {
      //   test: /\.module\.s(a|c)ss$/i,
      //   use: [
      //     "style-loader",
      //     "css-loader",
      //     "postcss-loader",
      //     {
      //       loader: "sass-loader",
      //       options: {
      //         // Prefer `dart-sass`
      //         implementation: require("sass"),
      //       },
      //     },
      //   ],
      // },
      // TODO; do we need this?
      // Add CSS/SASS/SCSS rule with loaders
      {
        test: /\.(?:sa|sc|c)ss$/i,
        use: [
          MiniCssExtractPlugin.loader,
          "style-loader",
          'css-loader',
          {
            loader: "sass-loader",
            options: {
              // Prefer `dart-sass`
              implementation: require("sass"),
            },
          },

        ],
      },
      // {
      //   test: /\.(woff|woff2|eot|ttf|otf)$/i,
      //   type: 'asset/resource',
      // },
    ]
  }
};
