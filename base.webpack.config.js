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

module.exports = {
  babel: {
    presets: ['es2015','stage-2']
  },
  eslint: {
    configFile: projectRoot + '/.eslintrc'
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
        enforce: "pre",
        test: /\.vue$/,
        loader: "eslint-loader",
        include: [
          projectRoot + '/dev',
          projectRoot + '/tests'
        ]
      },
      {
        test: /\.vue$/,
        loader: 'vue',
        include: includeDirs
      },
      {
        test: /\.js$/,
        loader: 'babel',
        include: includeDirs
      },
      {
        test: /\.json$/,
        loader: 'json',
        include: includeDirs
      },
      {
        test: /\.html$/,
        loader: 'vue-html',
        include: includeDirs
      },
      {
        test: /\.css$/,
        loader: 'style-loader!css-loader',
        include: includeDirs
      },
      {
        test: /\.less$/,
        loader: 'style-loader!less-loader',
        include: includeDirs
      },
      {
        test: /\.(woff2?|eot|ttf|otf|svg)(\?.*)?$/,
        loader: 'url',
        include: includeDirs
      }
    ]
  },
  vue: {
    loaders: {
      js: 'isparta'
    }
}
}
