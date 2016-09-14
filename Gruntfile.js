module.exports = function(grunt) {
  var include = require('include-all');
  function loadTasks(relPath) {
    return include({
      dirname: require('path').resolve(__dirname, relPath),
      filter: /(.+)\.js$/
    }) || {};
  }

  function configure(tasks) {
    for (var task in tasks) {
      if (tasks.hasOwnProperty(task)) {
        tasks[task](grunt);
      }
    }
  }

  var configs = loadTasks('./dev/tasks/config');
  var registeredTasks = loadTasks('./dev/tasks/register');

  if (!registeredTasks.default) {
    registeredTasks.default = function (grunt) {
      grunt.registerTask('default', []);
    };
  }

  configure(configs);
  configure(registeredTasks);
};
