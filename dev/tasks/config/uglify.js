module.exports = function(grunt) {
  grunt.config.set('uglify', {
    options: {
      preserveComments: false,
      sourceMap: true
    },
    flat: {
      src: 'pub/System/SearchGridPlugin/js/flatskin.js',
      dest: 'pub/System/SearchGridPlugin/js/flatskin.min.js'
    }
  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
};
