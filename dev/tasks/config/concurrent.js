module.exports = function(grunt) {
  grunt.config.set('concurrent', {
    options: {
      limit: 4
    },
    all: [
      ['sass', 'postcss:full', 'postcss:themify', 'cssmin'],
      ['concat:fndt', 'babel:fndt', 'uglify:fndt'],
      ['concat:flat', 'uglify:flat'],
      'copy:opensans'
    ],
    js: [
      ['concat:flat', 'uglify:flat']
    ]
  });

  grunt.loadNpmTasks('grunt-concurrent');
};
