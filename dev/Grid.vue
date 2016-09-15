<template>
    <ul><li v-for="item in results">{{item.author}} {{item.topic}}</li></ul>
</template>

<script>
export default {
    data : function () {
       return {
          results: []
       }
    },
    ready: function () {
       var prefs = JSON.parse($('.SEARCHGRIDPREF').html());
       var self = this;

       var results = $.get( "/bin/rest/SolrPlugin/proxy", {"q":prefs.q},function(result){
           self.results = result.response.docs;
        });
    }
}
</script>
