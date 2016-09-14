module.exports = function(grunt) {
  grunt.config.set('watch', {
    options: {
      interrupt: true
    },
    grunt: {
      files: ['Gruntfile.js', 'dev/tasks/**/*.js', 'dev/**/*.vue'],
      tasks: ['build']
    }
  });

  grunt.loadNpmTasks('grunt-contrib-watch');
};
