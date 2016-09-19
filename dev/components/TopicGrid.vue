<template>
    <br>{{prefs.filterHeading}}</br>
<template v-for="filter in prefs.filters">
<component :is="filter.component" :params="filter.params" :facet-values="facetValues" @filter-changed="filterChanged" @register-facet-field="registerFacetField"></component>
</template>
<table class="tablesortercopy">
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
<div>
  <template v-for="facet in prefs.facets">
    <component :is="facet.component" :params="facet.params" :facet-values="facetValues" @filter-changed="filterChanged" @register-facet-field="registerFacetField"></component>
  </template>
</div>
</template>

<script>
import GridHeader from './GridHeader.vue'
import TitleField from './fields/TitleField.vue'
import TextField from './fields/TextField.vue'
import DateField from './fields/DateField.vue'
import FullTextFilter from './filters/FullTextFilter.vue'
import SelectFilter from './filters/SelectFilter.vue'
import MultiSelectFacet from './facets/MultiSelectFacet.vue'
import SingleSelectFacet from './facets/SingleSelectFacet.vue'
import Paginator from 'vue-simple-pagination/VueSimplePagination.vue'
export default {
    data : function () {
       return {
          results: [],
          facetValues: {},
          request: null,
          numResults: 0,
          resultsPerPage: 0,
          currentPage: 1,
          sortField: "",
          sort: "",
          filterQuerys: {},
          facetFields: {},
          prefs: {},
          id: {}
       }
    },
    props: ['instances'],
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
      registerFacetField: function(field){
        this.facetFields[field]=field;
        //TODO: trigger fetch only once
        this.fetchData();
      },
      filterChanged: function(filterQuery, field){
        if(filterQuery === '') {
            delete this.filterQuerys[field];
        } else {
            this.filterQuerys[field] = filterQuery;
        }
        this.currentPage = 1;
        this.fetchData();
      },
      sortChanged: function(sortField, sort){
        this.sortField = sortField;
        this.sort = sort;
        this.fetchData();
      },
      fetchData: function(){
        if(this.request){
            this.request.abort();
        }
        var self = this;
        var params = {
          "q":this.prefs.q,
          "rows":this.resultsPerPage,
          "start": (this.currentPage - 1) * this.resultsPerPage,
          "facet": true,
        };
        params["fq"] = [];
        for (var key in this.filterQuerys) {
            params["fq"].push(key + ":" + this.filterQuerys[key]);
        }
        params["facet.field"] = [];
        for (var key in this.facetFields) {
            params["facet.field"].push(key);
        }

        if(this.sortField !== ""){
          params["sort"] = "" + this.sortField + " " + this.sort;
        }
        $.ajaxSettings.traditional = true;
        this.request = $.get( "/bin/rest/SearchGridPlugin/searchproxy", params, function(result){
            self.$set('numResults', result.response.numFound);
            self.$set('results', result.response.docs);
            if(result.facet_counts){
                var facetValues = result.facet_counts.facet_fields;
                var newFacetValues = {};
                for (var key in facetValues) {
                    var facet = [];
                    for(var i = 0; i < facetValues[key].length; i+=2){
                        facet.push({'title': facetValues[key][i],
                                    'count': facetValues[key][i+1]
                                   });
                    }
                    newFacetValues[key]=facet;
                }
                self.$set('facetValues', newFacetValues);
            }
            self.request = null;
        });
      }
    },
    components : {
      GridHeader,
      TitleField,
      TextField,
      DateField,
      FullTextFilter,
      SelectFilter,
      MultiSelectFacet,
      SingleSelectFacet,
      Paginator
    },
    ready: function () {
      var self = this;
      this.$set('prefs', JSON.parse($('.SEARCHGRIDPREF' + this.id).html()));
      self.$set('resultsPerPage', self.prefs.resultsPerPage);
      this.fetchData();
    },
    created: function () {
      this.$set('id', this.instances);
      this.$dispatch("update-instance-counter", this.instances);
    }
}
</script>

<style>

/*--------merely copied from tablesorter* --------------*/
/*Original doesnt work due to conflicts with vue*/
table.tablesortercopy {
  margin:10px 0pt 15px;
  width: 100%;
  text-align: left;
}

table.tablesortercopy thead tr th,
table.tablesortercopy tfoot tr th {
  background-color: #fff;
  color: #999;
  text-align: left;
  padding: 4px 20px 8px 4px;
  vertical-align: middle;
}

table.tablesortercopy.Modac_Standard thead tr th,
table.tablesortercopy.Modac_Standard tfoot tr th {
  background-color: #003c89;
  color: #fff;
  padding: 0 3px;
  text-align: center;
}

table.tablesortercopy tbody td {
  color: #3d3d3d;
  background-color: #fff;
  margin: 8px 1px;
  padding: 8px;
  background: #f8fcff;
}

table.tablesortercopy.Modac_Standard tbody td {
  background: #f9f9f9;
  padding: 0 3px;
}

table.tablesortercopy tbody tr.odd td {
  background-color:#f8fcff;
}

table.tablesortercopy thead tr .sorted {
  background-color: #fff;
  color: #000;
  font-weight: bold;
}
table.tablesortercopy thead tr .sortable {
  cursor: pointer;
}

table.tablesortercopy tr.even:hover td,
table.tablesortercopy tr.odd:hover td {
  background-color: #e8f7ff;
  margin: 8px 1px;
  padding: 8px;
}
</style>
