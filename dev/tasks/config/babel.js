module.exports = function(grunt) {
  grunt.config.set('babel', {
    options: {
      sourceMap: true,
      presets: ['es2015']
    },
    fndt: {
      files: {
        'pub/System/SearchGridPlugin/js/foundation.js':
          'pub/System/SearchGridPlugin/js/foundation.js'
      }
    }
  });

  grunt.loadNpmTasks('grunt-babel');
};



