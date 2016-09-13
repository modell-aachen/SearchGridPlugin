$(function() {
    var grid = new Vue({
        el: '#searchGrid',
        data: {
            searchQuery: '',
            results: []
        }
    });
    var prefs = JSON.parse($('.SEARCHGRIDPREF').html());

    var results = $.get( "/bin/rest/SolrPlugin/proxy", {"q":prefs._DEFAULT},function(result){
       Vue.set(grid.$data, 'results', result.response.docs);
    });
});
