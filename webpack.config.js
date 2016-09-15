var path = require('path')
var projectRoot = path.resolve(__dirname, '../../..')
var webpack = require('webpack')

module.exports = {
  babel: {
    presets: ['es2015']
  },
  entry: {
    app: './dev/main.js'
  },
  output: {
    path: path.join(__dirname, 'pub/System/SearchGridPlugin'),
    filename: 'searchGrid.js'
  },
  module: {
    loaders: [
      {
        test: /\.vue$/,
        loader: 'vue'
      },
      {
        test: /\.js$/,
        loader: 'babel',
        exclude: /node_modules/
      },
      {
        test: /\.json$/,
        loader: 'json'
      },
      {
        test: /\.html$/,
        loader: 'vue-html'
      }
    ]
  },
  vue: {
  plugins: [
  new webpack.optimize.UglifyJsPlugin({
      compress: false,
      mangle: false
    })
  ]
}
}
