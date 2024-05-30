const { generateWebpackConfig, merge } = require('shakapacker');
const baseWebpackConfig = generateWebpackConfig()
const TerserPlugin = require('terser-webpack-plugin');
const options = {
  // resolve: {
  //   extensions: ['.mjs', '.js', '.sass', '.scss', '.css', '.module.sass', '.module.scss', '.module.css', '.png', '.svg', '.gif', '.jpeg', '.jpg', '.json'],
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

      // Allow loading mp4 files (squarecrusher demo)
      {
        test: /\.mp4$/,
        use: [{
          loader: "file-loader",
          options: {
            name: "[name].[ext]",
            outputPath: "video"
          }
        }]
      },

      // // Optimize Images: Use image loaders and plugins to optimize images.
      // {
      //   test: /\.(png|jpe?g|gif|svg)$/i,
      //   use: [
      //     {
      //       loader: 'file-loader',
      //     },
      //     {
      //       loader: 'image-webpack-loader',
      //       options: {
      //         mozjpeg: {
      //           progressive: true,
      //           quality: 65,
      //         },
      //       },
      //     },
      //   ],
      // },
      {
        test: /\.module\.s(a|c)ss$/i,
        use: [
          "style-loader",
          "css-loader",
          "postcss-loader",
          {
            loader: "sass-loader",
            options: {
              // Prefer `dart-sass`
              implementation: require("sass"),
            },
          },
        ],
      },
    ],
  },
  optimization: {
    // Tree Shaking: Ensure that your project is set up to remove unused code.
    usedExports: true,

    // Split your code into smaller chunks that can be loaded on demand.
    splitChunks: {
      chunks: 'all',
    },

    // Minify your JavaScript files.
    minimize: true,
    minimizer: [new TerserPlugin()],
  },

  // Use Production Mode: Ensure webpack is running in production mode.
  mode: process.env.NODE_ENV,

};

module.exports = merge({}, baseWebpackConfig, options)

