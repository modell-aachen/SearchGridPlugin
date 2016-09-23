
<template>
<div class="searchGridWrapper">
  <div v-show="requestFailed" class="error">{{maketext("An error occured while processing the request:") + errorMessage}}</div>
  <div v-bind:class="{ 'invisible': !isLoading }" id="cssload-wrapper">
  <div id="cssload-border">
    <div id="cssload-whitespace">
      <div id="cssload-line">
      </div>
    </div>
  </div>
</div>
  <div v-if="showFilters" class="search-grid-filters">
    <template v-for="filter in prefs.filters">
      <component :is="filter.component" :params="filter.params" :facet-values="facetValues" @filter-changed="filterChanged" @register-facet-field="registerFacetField"></component>
    </template>
  </div>
  <div>
      <button v-if="showFilters" v-on:click="fetchData">Filter</button>
  </div>
  <div class="searchGridResults" v-bind:style="gridStyle">
    <table class="tablesortercopy">
      <thead is="grid-header" :headers="prefs.fields" :initial-sort="prefs.initialSort" @sort-changed="sortChanged"></thead>
      <tbody>
        <tr v-for="result in results">
          <template v-for="field in prefs.fields">
          <component :is="field.component" :doc="result" :params="field.params" :language="prefs.language"></component>
          </template>
        </tr>
      </tbody>
    </table>
    <paginator v-if="pageCount > 1" @page-changed="pageChanged" :page-count="pageCount" :current-page.sync="currentPage"></paginator>
  </div>
  <div v-if="showFacets" id="modacSolrRightBar">
    <h2 class='solrFilterResultsHeading' >{{maketext("Filter results")}}</h2>
    <button @click.stop="clearFacets()">{{maketext("Clear selection")}}</button>
    <template v-for="facet in prefs.facets">
    <component :is="facet.component" :params="facet.params" :facet-values="facetValues" @filter-changed="filterChanged" @register-facet-field="registerFacetField"></component>
    </template>
  </div>
</div>
</template>

<script>
import MaketextMixin from './MaketextMixin.vue'
import GridHeader from './GridHeader.vue'
import UrlField from './fields/UrlField.vue'
import UrlFormatField from './fields/UrlFormatField.vue'
import TextField from './fields/TextField.vue'
import DateField from './fields/DateField.vue'
import SolrField from './fields/SolrField.vue'
import FullTextFilter from './filters/FullTextFilter.vue'
import SelectFilter from './filters/SelectFilter.vue'
import MultiSelectFacet from './facets/MultiSelectFacet.vue'
import SingleSelectFacet from './facets/SingleSelectFacet.vue'
import Paginator from 'vue-simple-pagination/VueSimplePagination.vue'

export default {
    mixins: [MaketextMixin],
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
          prefs: {
            filters: [],
            facets: []
          },
          id: {},
          requestFailed: false,
          errorMessage: ""
       }
    },
    props: ['instances'],
    computed: {
      pageCount: function(){
        return Math.ceil(this.numResults / this.resultsPerPage);
      },
      showFilters: function(){
        return this.prefs.filters.length > 0;
      },
      showFacets: function(){
        return this.prefs.facets.length > 0;
      },
      isLoading: function() {
        return this.request != null;
      },
      gridStyle: function(){
        return {
          width: this.showFacets ? '' : '100%'
        }
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
        var self = this;
      },
      filterChanged: function(filterQuery, field, fetchData = true){
        if(filterQuery === '') {
            delete this.filterQuerys[field];
        } else {
            this.filterQuerys[field] = filterQuery;
        }
        this.currentPage = 1;
        if(fetchData)
          this.fetchData();
      },
      clearFacets: function () {
        this.$broadcast('reset');
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

        params["form"] = this.prefs.form;

        if(this.sortField !== ""){
          params["sort"] = "" + this.sortField + " " + this.sort;
        }
        $.ajaxSettings.traditional = true;
        this.request = $.get(foswiki.preferences.SCRIPTURL + "/rest/SearchGridPlugin/searchproxy", params)
        .done(function(result){
            result = JSON.parse(result);
            self.$set('numResults', result.response.numFound);
            self.$set('results', result.response.docs);
            self.setFacetValues(result);
            self.request = null;
            self.requestFailed = false;
        })
        .fail(function(xhr, status, error){
          if(xhr.statusText !== "abort"){
            self.requestFailed = true;
            self.errorMessage = xhr.statusText;
          }
          self.request = null;
        });
      },
      setFacetValues: function(result) {
          if(result.facet_counts){
              var facetValues = result.facet_counts.facet_fields;
              var newFacetValues = {};
              for (var key in facetValues) {
                  var facet = [];
                  for(var i = 0; i < facetValues[key].length; i+=2){
                      var field = facetValues[key][i];
                      var displayValue = "";
                      if(result.facet_dsps.hasOwnProperty(key) && result.facet_dsps[key].hasOwnProperty(field))
                      displayValue = result.facet_dsps[key][field];
                      else
                      displayValue = field;
                      facet.push({'title': displayValue,
                          'count': facetValues[key][i+1],
                          'field': field
                      });
                  }
                  newFacetValues[key]=facet;
              }
              this.$set('facetValues', newFacetValues);
          }
      }
    },
    components : {
      GridHeader,
      UrlField,
      UrlFormatField,
      TextField,
      DateField,
      SolrField,
      FullTextFilter,
      SelectFilter,
      MultiSelectFacet,
      SingleSelectFacet,
      Paginator
    },
    beforeCompile: function() {
      var self = this;
      var pref = JSON.parse($('.SEARCHGRIDPREF' + this.id).html());
      self.$set('prefs', pref);
      self.$set('resultsPerPage', pref.resultsPerPage);
      self.$set('numResults', pref.result.response.numFound);
      self.$set('results', pref.result.response.docs);
      if(this.prefs.hasOwnProperty("initialSort")){
        this.sortField = this.prefs.initialSort.field;
        this.sort = this.prefs.initialSort.sort;
      }
    },
    ready: function () {
      this.setFacetValues(this.prefs.result);
    },
    created: function () {
      this.$set('id', this.instances);
      this.$dispatch("update-instance-counter", this.instances);
    }
}
</script>

<style>
/*------------ facets --------*/
.searchGridWrapper {
  overflow: auto;
}
.searchGridResults {
  width: calc(100% - 16em);
  display: inline-block;
}
#modacSolrRightBar h2{
  font-weight: 600;
}

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

.search-grid-filters {
  float: left;
  width: 100%;
  margin-bottom: 5px;
}
#cssload-wrapper {
  width: 100%;
  height: 4px;
  overflow: hidden;
}

#cssload-wrapper.invisible {
  visibility: hidden;
}

#cssload-border {
  border: 1px solid rgb(255,255,255);
  height: 100%;
  width: 100%;
  left: -50%;
  top: -50%;
  padding: 1px 1px;
}

#cssload-whitespace {
  overflow: hidden;
  height: 100%;
  width: 100%;
  margin: 0 auto;
  overflow: hidden;
  position: relative;
}

#cssload-line {
  position: absolute;
  height: 100%;
  width: 100%;
  background-color: rgb(27,145,224);
  animation: cssload-slide 2s steps(120) infinite;
    -o-animation: cssload-slide 2s steps(120) infinite;
    -ms-animation: cssload-slide 2s steps(120) infinite;
    -webkit-animation: cssload-slide 2s steps(120) infinite;
    -moz-animation: cssload-slide 2s steps(120) infinite;
}



@keyframes cssload-slide {
  0% {
    left: -100%;
  }

  100% {
    left: 100%;
  }
}

@-o-keyframes cssload-slide {
  0% {
    left: -100%;
  }

  100% {
    left: 100%;
  }
}

@-ms-keyframes cssload-slide {
  0% {
    left: -100%;
  }

  100% {
    left: 100%;
  }
}

@-webkit-keyframes cssload-slide {
  0% {
    left: -100%;
  }

  100% {
    left: 100%;
  }
}

@-moz-keyframes cssload-slide {
  0% {
    left: -100%;
  }

  100% {
    left: 100%;
  }
}

.error {
  color: red;
}
</style>
