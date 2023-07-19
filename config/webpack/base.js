const { webpackConfig, merge } = require('@rails/webpacker');
const customConfig = {
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
      {
        test: /\.(webm|mp4|png|jpe?g|gif|svg)$/i,
        use: [{
          loader: 'file-loader',
          options: {
            name: '[path][name]-[hash].[ext]',
          }
        }]
      },

      // {
      //   test:/.scss$/,
      //   use: [
      //     "style-loader",
      //     "css-loader",
      //     "sass-loader"
      //   ],
      // },
      // {
      //   test: /\.css$/,
      //   use: [
      //     "style-loader",
      //     "css-loader"
      //   ]
      // }


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
    ]
  }
};

module.exports = merge(webpackConfig, customConfig);



// old environment.js config below:
//

// TODO: set these up
// Get the actual sass-loader config
// const sassLoader = environment.loaders.get('sass')
// const sassLoaderConfig = sassLoader.use.find(function (element) {
// return element.loader == 'sass-loader'
// })

// // Use Dart-implementation of Sass (default is node-sass)
// const options = sassLoaderConfig.options
// options.implementation = require('sass')

// module.exports = environment
