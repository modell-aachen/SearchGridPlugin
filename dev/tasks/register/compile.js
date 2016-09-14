module.exports = function(grunt) {
  grunt.registerTask('compile', [
    'clean',
    'webpack'
  ]);
};
