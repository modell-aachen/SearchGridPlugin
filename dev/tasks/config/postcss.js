module.exports = function(grunt) {
  grunt.config.set('postcss', {
    full: {
      options: {
        map: true,
        processors: [
          require('postcss-discard-duplicates')(),
          require('postcss-discard-empty')(),
          require('postcss-zindex')(),
          require('autoprefixer')({browsers: ['last 2 version']})
        ]
      },
      src: 'pub/System/SearchGridPlugin/css/flatskin.css'
    },
    themify: {
      options: {
        map: true,
        processors: [
          require('postcss-colors-only')
        ]
      },
      src: 'pub/System/SearchGridPlugin/css/flatskin.css',
      dest: 'pub/System/SearchGridPlugin/css/flatskin.colors.css'
    }
  });

  grunt.loadNpmTasks('grunt-postcss');
};
