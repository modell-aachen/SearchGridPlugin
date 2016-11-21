var baseConfig = require('./base.webpack.config.js');
var webpack = require('webpack');
var merge = require('webpack-merge');

module.exports = merge(baseConfig, {
	plugins: [
		new webpack.ProvidePlugin({
			$: "jquery",
			moment: "moment"
		})
	]
});