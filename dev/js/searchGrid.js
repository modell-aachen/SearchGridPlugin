$(function() {
    var grid = new Vue({
        el: '#searchGrid',
        data: {
            searchQuery: '',
            results: []
        },
        ready: function () {
            var prefs = JSON.parse($('.SEARCHGRIDPREF').html());

            var results = $.get( "/bin/rest/SolrPlugin/proxy", {"q":prefs._DEFAULT},function(result){
                grid.results = result.response.docs;
            });

        }
    });
});
