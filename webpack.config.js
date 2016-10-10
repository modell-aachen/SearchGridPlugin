var path = require('path')
var projectRoot = path.resolve(__dirname);
var webpack = require('webpack')

module.exports = {
  babel: {
    presets: ['es2015','stage-2']
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
        include: [
          projectRoot + '/dev',
          projectRoot + '/node_modules/vue-select/'
        ]
      },
      {
        test: /\.json$/,
        loader: 'json'
      },
      {
        test: /\.html$/,
        loader: 'vue-html'
      },
      {
        test: /\.css$/,
        loader: 'style-loader!css-loader'
      },
      {
        test: /\.less$/,
        loader: 'style-loader!less-loader'
      },
      {
        test: /\.(woff2?|eot|ttf|otf|svg)(\?.*)?$/,
        loader: 'url'
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
