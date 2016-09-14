module.exports = function(grunt) {
  grunt.config.set('cssmin', {
    options: {
      keepSpecialComments: 0,
      sourceMap: true
    },
    dev: {
      files: {
        'pub/System/SearchGridPlugin/css/flatskin.min.css':
          'pub/System/SearchGridPlugin/css/flatskin.css',
        'pub/System/SearchGridPlugin/css/flatskin.colors.min.css':
          'pub/System/SearchGridPlugin/css/flatskin.colors.css'
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-cssmin');
};
