<template>
<div id="loading-bar">
</div>
<div class="search-grid" style="display:flex;">
<div class="searchGridWrapper" v-bind:style="gridStyle">
  <div v-show="requestFailed" class="error">{{maketext("An error occured while processing the request:") + errorMessage}}</div>
  <div v-if="showFilters" class="search-grid-filters">
    <template v-for="filter in prefs.filters">
      <component :is="filter.component" :params="filter.params" :facet-values="facetValues" @facet-changed="facetChanged" @register-facet="registerFacet"></component>
    </template>
  </div>
  <div>
      <button v-if="showFilters" v-on:click="fetchData">Filter</button>
  </div>
  <div class="searchGridResults flatskin-wrapped">
    <table class="ma-table">
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
</div>
<div v-if="showFacets" style="flex: 1; margin: 5px;">
  <h1 class='solrFilterResultsHeading' >{{maketext("Facets")}}</h1>
  <button @click.stop="clearFacets()">{{maketext("Reset all")}}</button>
  <template v-for="facet in prefs.facets">
  <component :is="facet.component" :params="facet.params" :facet-values="facetValues" @facet-changed="facetChanged" :facet-total-counts="prefs.result.facetTotalCounts" @get-facet-info="fetchFacetCharacteristics" @register-facet="registerFacet"></component>
  </template>
</div>
<div>
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
import Select2Facet from './facets/Select2Facet.vue'
import Paginator from 'vue-simple-pagination/VueSimplePagination.vue'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'

export default {
    mixins: [MaketextMixin],
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
      Select2Facet,
      Paginator
    },
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
          errorMessage: "",
          facets: [],
          filters: []
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
        if(this.showFacets){
          return {
            flex: "0 0 75%",
            margin: "5px"
          };
        }
        else{
          return {
            width: "100%"
          };
        }
      }
    },
    methods: {
      pageChanged: function(){
        var self = this;
        self.$set('resultsPerPage', self.prefs.resultsPerPage);
        this.fetchData();
      },
      registerFacet: function(facet){
        this.facets.push(facet);
      },
      facetChanged: function(){
        this.currentPage = 1;
        this.fetchData();
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
      collectFilterQueries: function(){
        var filterQueries = [];
        for(var i = 0; i < this.facets.length; i++){
          if(this.facets[i].filterQuery)
            filterQueries.push(this.facets[i].filterQuery);
        }
        return filterQueries;
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
          "facet.limit": 5,
          "facet.sort": "count",
          "fl" : this.prefs.fieldRestriction,
          form: this.prefs.form
        };

        params["facet.field"] = [];
        params["fq"] = this.collectFilterQueries();
        for(var i = 0; i < this.facets.length; i++){
          params["facet.field"].push(this.facets[i].facetField);
          params[`f.${this.facets[i].field}.facet.limit`] = this.facets[i].limit;
        }

        if(this.sortField !== ""){
          params["sort"] = "" + this.sortField + " " + this.sort;
        }
        $.ajaxSettings.traditional = true;

        NProgress.start();
        this.request = $.get(foswiki.preferences.SCRIPTURL + "/rest/SearchGridPlugin/searchproxy", params)
        .done(function(result){
            result = JSON.parse(result);
            self.$set('numResults', result.response.numFound);
            self.$set('results', result.response.docs);
            self.parseAllFacetResults(result);
            self.request = null;
            self.requestFailed = false;
            NProgress.done();
        })
        .fail(function(xhr, status, error){
          if(xhr.statusText !== "abort"){
            self.requestFailed = true;
            self.errorMessage = xhr.statusText;
          }
          NProgress.done();
          self.request = null;
        });
      },
      fetchFacetCharacteristics: function(facet, searchTerm, offset, callback){
        var searchTermKey = `f.${facet.field}.facet.contains`;
        var ignoreCaseKey = `f.${facet.field}.facet.contains.ignoreCase`;
        var params = {
          "q":this.prefs.q,
          "rows": 0,
          "facet": true,
          "facet.field": facet.facetField,
          "facet.offset": offset,
          "facet.limit": facet.limit,
          "facet.sort": "count",
          form: this.prefs.form
        };

        if(searchTerm !== ""){
          params[searchTermKey] = searchTerm;
          params[ignoreCaseKey] = true;
        }
        params["fq"] = this.collectFilterQueries();

        var self = this;

        $.get(foswiki.preferences.SCRIPTURL + "/rest/SearchGridPlugin/searchproxy", params)
        .done(function(result){
          result = JSON.parse(result);
          var parsedResult = self.parseFacetResult(facet.field, result.facet_counts.facet_fields[facet.field], result.facet_dsps);
          callback(parsedResult);
        });
      },
      parseFacetResult: function(facetField, facetResult, facetDisplayValues) {
            var facet = [];
            for(var i = 0; i < facetResult.length; i+=2){
                var field = facetResult[i];
                var displayValue = "";
                if(facetDisplayValues.hasOwnProperty(facetField) && facetDisplayValues[facetField].hasOwnProperty(field))
                  displayValue = facetDisplayValues[facetField][field];
                else
                  displayValue = field;

                facet.push({
                  'title': displayValue,
                  'count': facetResult[i+1],
                  'field': field
                });
        }
        return facet;
      },
      parseAllFacetResults: function(result){
        if(result.facet_counts){
          var parsedFacetValues = {};
          var facetValues = result.facet_counts.facet_fields;
          var newFacetValues = {};
          for (var key in facetValues) {
              parsedFacetValues[key] = this.parseFacetResult(key, facetValues[key], result.facet_dsps);
          }
          this.$set("facetValues", parsedFacetValues);
        }
      }
    },
    created: function () {
      this.id = this.instances;
      this.$dispatch("update-instance-counter", this.id);
    },
    beforeCompile: function() {
      this.prefs = JSON.parse($('.SEARCHGRIDPREF' + this.id).html());
      this.resultsPerPage = this.prefs.resultsPerPage;
      this.numResults = this.prefs.result.response.numFound;
      this.results = this.prefs.result.response.docs;
      if(this.prefs.hasOwnProperty("initialSort")){
        this.sortField = this.prefs.initialSort.field;
        this.sort = this.prefs.initialSort.sort;
      }
      this.parseAllFacetResults(this.prefs.result);

      NProgress.configure({
        parent: '#loading-bar',
        showSpinner: false
      });
    }
}
</script>

<style lang="sass">
/*------------ facets --------*/
.searchGridResults {
  width: 100%;
  display: inline-block;
}

.search-grid-filters {
  float: left;
  width: 100%;
  margin-bottom: 5px;
}
#loading-bar {
  width: 100%;
  height: 4px;
  overflow: hidden;
  &.invisible {
    visibility: hidden;
  }
}

.error {
  color: red;
}
</style>
