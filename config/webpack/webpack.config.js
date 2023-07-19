//
// TODO: use this config when we upgrade to shakapacker 7
//
// const { generateWebpackConfig, merge } = require('shakapacker');
// const baseWebpackConfig = generateWebpackConfig()
// const options = {
//   // resolve: {
//   //   extensions: ['.mjs', '.js', '.sass', '.scss', '.css', '.module.sass', '.module.scss', '.module.css', '.png', '.svg', '.gif', '.jpeg', '.jpg', '.json'],
//   // },
//   module: {
//     rules: [
//       {
//         test: require.resolve('jquery'),
//         loader: 'expose-loader',
//         options: {
//           exposes: ['$', 'jQuery']
//         }
//       },
//       // {
//       //   test: /\.(|png|jpe?g|gif|svg)$/i,
//       //   use: [{
//       //     loader: 'file-loader',
//       //     options: {
//       //       name: '[path][name]-[hash].[ext]',
//       //     }
//       //   }]
//       // },
//       {
//         test: /\.mp4$/,
//         use: [{
//           loader: "file-loader",
//           options: {
//             name: "[name].[ext]",
//             outputPath: "video"
//           }
//         }]
//       },
//       {
//         test: /\.module\.s(a|c)ss$/i,
//         use: [
//           "style-loader",
//           "css-loader",
//           "postcss-loader",
//           {
//             loader: "sass-loader",
//             options: {
//               // Prefer `dart-sass`
//               implementation: require("sass"),
//             },
//           },
//         ],
//       },
//     ]
//   }
// };

// module.exports = merge({}, baseWebpackConfig, options)

const { webpackConfig, merge } = require('shakapacker');
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
      // {
      //   test: /\.(|png|jpe?g|gif|svg)$/i,
      //   use: [{
      //     loader: 'file-loader',
      //     options: {
      //       name: '[path][name]-[hash].[ext]',
      //     }
      //   }]
      // },
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
