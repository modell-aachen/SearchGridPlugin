module.exports = function(grunt) {
  grunt.config.set('clean', {
    dev: [
      'pub/System/SearchGridPlugin/css/flatskin.*',
      'pub/System/SearchGridPlugin/js/flatskin.*',
      'pub/System/SearchGridPlugin/js/foundation.*',
      'pub/System/SearchGridPlugin/fonts/opensans/**'
    ]
  });

  grunt.loadNpmTasks('grunt-contrib-clean');
};
