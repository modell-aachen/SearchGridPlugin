module.exports = function(grunt) {
  grunt.config.set('concat', {
    options: {
      separator: ';\n',
      sourceMap: true
    },
    fndt: {
      files: {
        'pub/System/SearchGridPlugin/js/foundation.js': [
          'node_modules/foundation-sites/js/foundation.core.js',
          'node_modules/foundation-sites/js/foundation.util.mediaQuery.js',
          'node_modules/foundation-sites/js/foundation.util.box.js',
          'node_modules/foundation-sites/js/foundation.util.keyboard.js',
          'node_modules/foundation-sites/js/foundation.util.nest.js',
          'node_modules/foundation-sites/js/foundation.util.triggers.js',
          'node_modules/foundation-sites/js/foundation.dropdownMenu.js',
          'node_modules/foundation-sites/js/foundation.sticky.js'
        ]
      }
    },
    flat: {
      files: {
        'pub/System/SearchGridPlugin/js/searchGrid.js': [
          'dev/js/**/*.js'
        ]
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-concat');
};
