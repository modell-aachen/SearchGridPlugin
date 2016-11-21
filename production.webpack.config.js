var baseConfig = require('./base.webpack.config.js');
var webpack = require('webpack');
var merge = require('webpack-merge');

module.exports = merge(baseConfig, {
	plugins: [
		new webpack.optimize.DedupePlugin(),
		new webpack.optimize.UglifyJsPlugin(),
		new webpack.optimize.AggressiveMergingPlugin()
	]
});