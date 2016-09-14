module.exports = function(grunt) {
  grunt.config.set('watch', {
    options: {
      interrupt: true
    },
    grunt: {
      files: ['Gruntfile.js', 'dev/tasks/**/*.js'],
      tasks: ['build']
    },
    sass: {
      files: ['dev/sass/**/*.scss'],
      tasks: ['sass', 'cssmin']
    },
    js: {
      files: ['dev/js/**/*.js'],
      tasks: ['concurrent:js']
    }
  });

  grunt.loadNpmTasks('grunt-contrib-watch');
};
