<template>
<table>
  <thead is="grid-header" :headers="prefs.fields" @sort-changed="sortChanged"></thead>
  <tbody>
    <tr v-for="result in results">
      <template v-for="field in prefs.fields">
      <component :is="field.component" :params="paramsToData(field.params, result)"></component>
      </template>
    </tr>
  </tbody>
</table>
<paginator v-if="pageCount > 1" @page-changed="pageChanged" :page-count="pageCount" :current-page.sync="currentPage"></paginator>
</template>

<script>
import GridHeader from './GridHeader.vue'
import TitleField from './fields/TitleField.vue'
import TextField from './fields/TextField.vue'
import DateField from './fields/DateField.vue'
import Paginator from 'vue-simple-pagination/VueSimplePagination.vue'
export default {
    data : function () {
       return {
          results: [],
          numResults: 0,
          resultsPerPage: 0,
          currentPage: 1,
          sortField: "",
          sort: "",
          prefs: {}
       }
    },
    computed: {
      pageCount: function(){
        return Math.ceil(this.numResults / this.resultsPerPage);
      }
    },
    methods: {
      paramsToData : function(params, queryResult){
        var result = [];
        for(var i = 0; i < params.length; i++){
          var key= params[i];
          result.push(queryResult[key]);
        }
        return result;
      },
      pageChanged: function(){
        var self = this;
        self.$set('resultsPerPage', self.prefs.resultsPerPage);
        this.fetchData();
      },
      sortChanged: function(sortField, sort){
        this.sortField = sortField;
        this.sort = sort;
        this.fetchData();
      },
      fetchData: function(){
        var self = this;
        var params = {
          "q":this.prefs.q,
          "rows":this.resultsPerPage,
          "start": (this.currentPage - 1) * this.resultsPerPage,
        };
        if(this.sortField !== ""){
          params["sort"] = "" + this.sortField + " " + this.sort;
        }
        $.get( "/bin/rest/SearchGridPlugin/searchproxy", params, function(result){
            self.$set('numResults', result.response.numFound);
            self.$set('results', result.response.docs);
        });
      }
    },
    components : {
      GridHeader,
      TitleField,
      TextField,
      DateField,
      Paginator
    },
    ready: function () {
      var self = this;
      this.$set('prefs', JSON.parse($('.SEARCHGRIDPREF').html()));
      self.$set('resultsPerPage', self.prefs.resultsPerPage);
      this.fetchData();
    }
}
</script>
