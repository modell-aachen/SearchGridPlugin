module.exports = function(grunt) {
	var webpack = require("webpack");
	var webpackConfig = require("../../../webpack.config.js");
	grunt.config.set('webpack', {
		webpack: {
				options: webpackConfig,
		}
  });

  grunt.loadNpmTasks('grunt-webpack');
};
