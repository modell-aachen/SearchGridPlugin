module.exports = function(grunt) {
  grunt.config.set('clean', {
    dev: [
      'pub/System/SearchGridPlugin/*',
    ]
  });

  grunt.loadNpmTasks('grunt-contrib-clean');
};
