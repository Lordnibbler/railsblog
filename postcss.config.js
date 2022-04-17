module.exports = {
  plugins: [
    require('postcss-import'),
    require('postcss-url'),
    require('autoprefixer'),
    require("tailwindcss"),
    require('postcss-flexbugs-fixes'),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    })
  ]
}
