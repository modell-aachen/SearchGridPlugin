var path = require('path')
var projectRoot = path.resolve(__dirname);
var webpack = require('webpack')

var includeDirs = [
  projectRoot + '/dev',
  projectRoot + '/node_modules/vue-select/',
  projectRoot + '/node_modules/nprogress/',
  projectRoot + '/node_modules/vue-simple-pagination/',
  projectRoot + '/tests'
];

var babelLoaderOptions = {
  presets: ['es2015','stage-2']
}

module.exports = {
  resolve: {
    extensions: ['.vue', '.js']
  },
  entry: {
    app: ['./dev/main.js']
  },
  output: {
    path: path.join(__dirname, 'pub/System/SearchGridPlugin'),
    filename: 'searchGrid.js'
  },
  devtool: "source-map",
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader',
        include: includeDirs,
         options: {
           loaders: {
            js:'babel-loader?' + JSON.stringify(babelLoaderOptions)
          },
       }
      },
      {
        test: /\.js$/,
        loader: 'babel-loader',
        include: includeDirs,
        options: babelLoaderOptions
      },
      {
        test: /\.css$/,
        include: includeDirs,
        use: [
          "style-loader",
          "css-loader"
        ]
      },
      {
        test: /\.(woff2?|eot|ttf|otf|svg)(\?.*)?$/,
        loader: 'url-loader',
        include: includeDirs
      }
    ]
  }
}
