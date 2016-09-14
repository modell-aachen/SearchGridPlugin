module.exports = function(grunt) {
  grunt.registerTask('compile', [
    'clean',
    'concurrent:all'
  ]);
};
