module.exports = function(grunt) {
  grunt.config.set('sass', {
    flat: {
      options: {
        includePaths: [
          'node_modules'
        ],
        outputStlye: 'expanded',
        sourceMap: true
      },
      files: [{
        expand: true,
        cwd: 'dev/sass/',
        src: ['flatskin.scss'],
        dest: 'pub/System/SearchGridPlugin/css/',
        ext: '.css',
      }]
    }
  });

  grunt.loadNpmTasks('grunt-sass');
};
