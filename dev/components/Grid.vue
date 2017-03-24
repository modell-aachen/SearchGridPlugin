<template>
    <div class="flatskin-wrapped">
        <div class="expanded row">
            <!--Toplevel container -->
            <div class="columns">
                <!-- Filters and table -->
                <div v-if="showFilters" class="expanded row wrapper search-grid-filters">
                    <!-- Filters -->
                    <div>
                        <div class="expanded row align-bottom">
                            <template v-for="filter in prefs.filters">
                            <!-- TODO debounce 700 -->
                                <component v-if="hasLiveFilter" v-on:keyup="applyFilters" v-on:keyup.enter="applyFilters" :is="filter.component" :params="filter.params" :facet-values="facetValues" @facet-changed="facetChanged" @register-facet="registerFacet"></component>
                                <component v-else v-on:keyup.enter="applyFilters" :is="filter.component" :params="filter.params" :facet-values="facetValues" @facet-changed="facetChanged" @register-facet="registerFacet"></component>
                            </template>
                            <div class="columns">
                                <div class="button-group">
                                    <a class="primary button" v-on:click="applyFilters">{{maketext("Apply filters")}}</a>
                                    <a class="alert button" v-show="isFilterApplied" v-on:click="clearFilters">{{maketext("Remove filters")}}</a>
                                </div>
                            </div>
                            <div class="columns">
                              <template v-for="addon in prefs.addons">
                                <component :is="addon" :api="api">
                                </component>
                              </template>
                            </div>
                            <div class="shrink columns">
                                <div class="grid-toggle button-group">
                                    <a v-if="hasGridView" v-bind:class="{disabled: isGridView, selected: !isGridView}" class="small button" @click.stop="toggleGridView('table')">
                                        <i class="fa fa-bars" aria-hidden="true"></i>
                                    </a>
                                    <a v-if="hasGridView" v-bind:class="{disabled: !isGridView, selected: isGridView}" class="small button" @click.stop="toggleGridView('grid')">
                                        <i class="fa fa-th-large" aria-hidden="true"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="expanded row" v-bind:class="isGridView ? ['medium-up-1', 'xlarge-up-2', 'xxxlarge-up-3', 'xxxxlarge-up-4'] : []">
                    <!-- Table -->
                    <div class="columns" v-show="results.length == 0"><p>{{maketext("No results")}}</p></div>
                    <div v-show="!isGridView && results.length > 0" class="columns search-grid-results">
                        <table>
                            <thead is="grid-header" :headers="filteredFields" :initial-sort="prefs.initialSort"></thead>
                            <tbody>
                                <tr v-for="result in results">
                                    <td v-for="field in filteredFields" :is="field.component" :doc="result" :params="field.params">
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div v-if="hasGridView" v-show="isGridView && results.length > 0" class="columns" v-for="result in results">
                        <div :is="prefs.gridField.component" :doc="result" :params="prefs.gridField.params"></div>
                    </div>
                </div>
                <div class="expanded row">
                    <div class="columns">
                    <!-- TODO current-page.sync -->
                        <paginator class="ma-pager-new" v-if="pageCount > 1" v-on:page-changed="pageChanged" :page-count="pageCount" :current-page="gridState.currentPage"></paginator>
                    </div>
                </div>
            </div>
            <div class="small-3 columns search-grid-facets" v-if="showFacets">
                <!-- Facets -->
                <div class="wrapper">
                    <div>
                        <h1 class='primary facets-header'><a class="small filter-reset button float-right" @click.stop="clearFacets()">{{maketext("Reset all")}}<i class="fa fa-times fa-lg" aria-hidden="true"></i></a>{{maketext("Facets")}}</h1>
                        <template v-for="facet in prefs.facets">
                            <component :is="facet.component" :params="facet.params" :facet-values="facetValues" @facet-changed="facetChanged" :facet-total-counts="prefs.result.facetTotalCounts" @get-facet-info="fetchFacetCharacteristics" @register-facet="registerFacet"></component>
                        </template>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>


<script>
/*global $ foswiki*/
import MaketextMixin from './MaketextMixin.vue'
import GridHeader from './GridHeader.vue'
import UrlField from './fields/UrlField.vue'
import UrlFormatField from './fields/UrlFormatField.vue'
import TextField from './fields/TextField.vue'
import DateField from './fields/DateField.vue'
import SolrField from './fields/SolrField.vue'
import ImageField from './fields/ImageField.vue'
import TestGridField from './fields/TestGridField.vue'
import FullTextFilter from './filters/FullTextFilter.vue'
import SelectFilter from './filters/SelectFilter.vue'
import MultiSelectFacet from './facets/MultiSelectFacet.vue'
import SingleSelectFacet from './facets/SingleSelectFacet.vue'
import Select2Facet from './facets/Select2Facet.vue'
import Paginator from 'vue-simple-pagination/VueSimplePagination.vue'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'
import * as mutations from "../store/mutation-types";

export default {
    mixins: [MaketextMixin],
    components : {
      GridHeader,
      UrlField,
      UrlFormatField,
      TextField,
      DateField,
      SolrField,
      ImageField,
      TestGridField,
      FullTextFilter,
      SelectFilter,
      MultiSelectFacet,
      SingleSelectFacet,
      Select2Facet,
      Paginator
    },
    data : function () {
       return {
          gridState: null,
          facetValues: {},
          request: null,
          filterQuerys: {},
          facetFields: {},
          prefs: {
            filters: [],
            facets: [],
            fields: []
          },
          id: {},
          requestFailed: false,
          errorMessage: "",
          filters: [],
          isFilterApplied: false,
          hasGridView: false,
          hasLiveFilter: false,
          columnsToHide: [],
          initialHideColumn: false, 
          isGridView: false
       }
    },
    props: ['preferencesSelector'],
    computed: {
      currentPage: {
        get() {
          return this.gridState.currentPage;
        },
        set(value) {
          this.$store.commit("searchGrid/" + mutations.SET_CURRENT_PAGE, {gridState: this.gridState, page: value});
        }
      },
      sortCrits: {
        get() {
          return this.gridState.sortCrits;
        },
        set(value) {
          this.$store.commit("searchGrid/" + mutations.CHANGE_SORT, {gridState: this.gridState, sortCrits: value});
        }
      },
      results: {
        get() {
          return this.gridState.results;
        },
        set(value) {
          this.$store.commit("searchGrid/" + mutations.SET_RESULTS, {gridState: this.gridState, results: value});
        }
      },
      resultsPerPage: {
        get() {
          return this.gridState.resultsPerPage;
        },
        set(value) {
          this.$store.commit("searchGrid/" + mutations.SET_RESULTS_PER_PAGE, {gridState: this.gridState, resultsPerPage: value});
        }
      },
      numResults: {
        get() {
          return this.gridState.numResults;
        },
        set(value) {
          this.$store.commit("searchGrid/" + mutations.SET_NUM_RESULTS, {gridState: this.gridState, numResults: value});
        }
      },
      facets(){
        return this.gridState.facets;
      },
      pageCount: function(){
        return Math.ceil(this.numResults / this.resultsPerPage);
      },
      showFilters: function( ){
        return this.prefs.filters.length > 0;
      },
      showFacets: function(){
        return this.prefs.facets.length > 0;
      },
      isLoading: function() {
        return this.request != null;
      },
      filteredFields: function(){
        let self = this;
        return this.prefs.fields.filter(function(value,index){
          //return !self.columnsToHide.includes(index);
          return !self.arrayIncludesValue(self.columnsToHide,index);
        });
      },
      api: function() {
        return {
          isGridView: this.isGridView,
          showColumns: this.showColumns,
          hideColumns: this.hideColumns,
          initialHideColumn: this.initialHideColumn
        };
      }
    },
    methods: {
      hideColumns: function(columns){
        this.columnsToHide = this.columnsToHide.concat(columns);
      },
      showColumns: function(columns){
        let self = this;
        this.columnsToHide = this.columnsToHide.filter(function(value){
          //return !columns.includes(value);
          return !self.arrayIncludesValue(columns,value);
        });
      },
      arrayIncludesValue(array,value){
        for(var i=0;i<array.length;i++){
          if(array[i] === value)
            return true;
        }
        return false;
      },
      pageChanged: function(newPage){
        this.currentPage = newPage;
        this.fetchData();
      },
      toggleGridView: function(changeTo) {
        if(changeTo === "table" && !this.isGridView)
          return;
        if(changeTo === "grid" && this.isGridView)
          return;

        this.isGridView = !this.isGridView;
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
        //TODO this.DOLLARbroadcast('reset');
        for(var i = 0; i < this.facets.length; i++){
          //Only filters have the 'isDefault' property
          if(!this.facets[i].isFilter){
            this.facets[i].reset();
          }
        }
        this.$nextTick(function(){
          this.fetchData();
        });
      },
      clearFilters: function(){
        //TODO this.DOLLARbroadcast('clear-filters');
        this.isFilterApplied = false;
        for(var i = 0; i < this.facets.length; i++){
          //Only filters have the 'isDefault' property
          if(this.facets[i].isFilter){
            this.facets[i].reset();
          }
        }
        this.$nextTick(function(){
          this.fetchData();
        });
      },
      applyFilters: function(){
        //TODO:
        //Currently all filters are stored in the facets array.
        //Here we want to check whether any of them is not on the default
        //value. It would be better if they would register in their own array
        //in addition to the facet arrray.
        this.isFilterApplied = false;
        for(var i = 0; i < this.facets.length; i++){
          //Only filters have the 'isDefault' property
          if(this.facets[i].isFilter &&
             !this.facets[i].isDefault){
            this.isFilterApplied = true;
            break;
          }
        }
        this.fetchData(true);
      },
      sortCritsToString: function() {
        var result = "";
        for(var i = 0; i < this.sortCrits.length; i++) {
          result += this.sortCrits[i].field + " " + this.sortCrits[i].order + ",";
        }
        result = result.slice(0,result.length-1); // drop last comma
        return result;
      },
      collectFilterQueries: function(){
        var filterQueries = [];
        for(var i = 0; i < this.facets.length; i++){
          if(this.facets[i].filterQuery)
            filterQueries.push(this.facets[i].filterQuery);
        }
        return filterQueries;
      },
      fetchData: function(search){
        //Search via filters or query for next page? Query over all elements : Skip results on former pages 
        var startpoint  = search? 0 : (this.currentPage - 1) * this.resultsPerPage;
        if(this.request){
            this.request.abort();
        }
        var self = this;
        var params = {
          "topic": foswiki.preferences.WEB + "." + foswiki.preferences.TOPIC,
          "q":this.prefs.q,
          "rows":this.resultsPerPage,
          "start": startpoint,
          "facet": true,
          "facet.limit": 5,
          "facet.sort": "count",
          "fl" : this.prefs.fieldRestriction,
          form: this.prefs.form
        };

        params["facet.field"] = [];
        params["fq"] = this.collectFilterQueries();
        // If there are no filterquerys, the whole set is loaded and the currentpage has to be set to page 1
        //TODO Check if still relevant
        // if(params["fq"].length == 0){
        //   this.currentPage = 1;
        // }
        for(var i = 0; i < this.facets.length; i++){
          params["facet.field"].push(this.facets[i].facetField);
          if(!this.facets[i].isFilter)
            params[`f.${this.facets[i].field}.facet.limit`] = this.facets[i].limit;
        }

        if(this.sortCrits !== []){
          params["sort"] = this.sortCritsToString();
        }
        $.ajaxSettings.traditional = true;

        NProgress.start();
        this.request = $.get(foswiki.preferences.SCRIPTURL + "/rest/SearchGridPlugin/searchproxy", params)
        .done(function(result){
            result = JSON.parse(result);
            self.numResults = result.response.numFound;
            self.results = result.response.docs;
            self.parseAllFacetResults(result);
            self.request = null;
            self.requestFailed = false;
            NProgress.done();
        })
        .fail(function(xhr){
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

                //Remove empty/whitespace entries to not feel broken
                if(field.match(/^\s*$/))
                  continue;

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
          for (var key in facetValues) {
              parsedFacetValues[key] = this.parseFacetResult(key, facetValues[key], result.facet_dsps);
          }
          this.facetValues = parsedFacetValues;
        }
      }
    },
    created: function() {
      let self = this;
      this.$store.dispatch('searchGrid/addGridState', {callback: function(gridState){
                self.gridState = gridState;
      }});
      this.prefs = JSON.parse($('.' + this.preferencesSelector).html());
      this.resultsPerPage = this.prefs.resultsPerPage;
      this.numResults = this.prefs.result.response.numFound;
      this.results = this.prefs.result.response.docs;
      this.hasGridView = this.prefs.hasOwnProperty('gridField');
      this.hasLiveFilter = this.prefs.hasLiveFilter;
      this.initialHideColumn = this.prefs.initialHideColumn;
      if(this.prefs.hasOwnProperty("initialSort")){
        var sortCrits = this.prefs.initialSort.split(",");
        let initialSortCrits = [];
        for(var i = 0; i < sortCrits.length; i++) {
          var splitted = sortCrits[i].split(" ");
          initialSortCrits.push({field: splitted[0], order: splitted[1]});
        }
        this.sortCrits = initialSortCrits;
      }
      if(this.prefs.initialFiltering){
        this.isFilterApplied = true;
      }
      this.parseAllFacetResults(this.prefs.result);

      NProgress.configure({
        showSpinner: false
      });
    },
    mounted() {
      this.$watch("sortCrits", function(){
        this.fetchData();
      });
    }
}
</script>

<style lang="sass">
.searchGridWrapper {
  overflow: auto;
}

.error {
  color: red;
}

h1.facets-header {
  margin: 0px;
}

.filter-reset {
  i {
    margin-left: 5px;
  }
}

.search-grid-filters {
  margin-bottom: 10px;
  .input-group,
  .button-group,
  .button-group .button,
  select,
   {
    margin-bottom: 0px;
  }
}

.columns.search-grid-results {
  padding-left: 0;
  padding-right: 0;
}

.grid-toggle .button {
  &.selected {
    cursor: default;
  }
  &.disabled{
    cursor: pointer;
  }
}
</style>
