<template>
    <div class="flatskin-wrapped">
        <div class="expanded row">
            <!--Toplevel container -->
            <div class="columns">
                <!-- Filters and table -->
                <div v-if="showTopActionBar" class="expanded row wrapper search-grid-top-bar">
                    <!-- Filters -->
                    <div>
                        <div class="expanded row align-bottom">
                            <template v-for="filter in prefs.filters">
                                <component v-if="hasLiveFilter" v-on:filter-change="applyFiltersDebounce" v-on:confirm="applyFilters" :is="filter.component" :params="filter.params" :facet-values="facetValues" @facet-changed="facetChanged" @register-facet="registerFacet"></component>
                                <component v-else v-on:confirm="applyFilters" :is="filter.component" :params="filter.params" :facet-values="facetValues" @facet-changed="facetChanged" @register-facet="registerFacet"></component>
                            </template>
                            <div v-if="hasFilters" class="columns">
                                <div class="button-group">
                                    <a class="primary button" v-on:click="applyFilters">{{maketext("Apply filters")}}</a>
                                    <a class="alert button" v-show="isFilterApplied" v-on:click="clearFilters">{{maketext("Remove filters")}}</a>
                                </div>
                            </div>
                            <div class="columns">
                              <!--
                                  Separator which forces the following
                                  shrinked columns to align to the right
                               -->
                            </div>
                            <div v-if="hasAddons" class="shrink columns">
                              <template v-for="addon in prefs.addons">
                                <component :is="addon" :api="api">
                                </component>
                              </template>
                            </div>
                            <div v-if="hasExcelExport" class="shrink columns">
                              <div class="button-group">
                                <excel-export :fields="prefs.fields"></excel-export>
                              </div>
                            </div>
                            <div v-if="hasGridView" class="shrink columns">
                                <div class="grid-toggle button-group">
                                    <a v-bind:class="{disabled: isGridView, selected: !isGridView}" class="small button" @click.stop="toggleGridView('table')">
                                        <i class="fa fa-bars" aria-hidden="true"></i>
                                    </a>
                                    <a v-bind:class="{disabled: !isGridView, selected: isGridView}" class="small button" @click.stop="toggleGridView('grid')">
                                        <i class="fa fa-th-large" aria-hidden="true"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="expanded row" v-bind:class="isGridView ? ['medium-up-1', 'xlarge-up-2', 'xxxlarge-up-3', 'xxxxlarge-up-3'] : []">
                    <!-- Table -->
                    <div class="columns" v-show="results.length == 0"><p>{{maketext("No results")}}</p></div>
                    <div class="columns" v-show="results.status == 'error'"><p>{{maketext(results.msg)}}</p></div>
                    <div v-show="!isGridView && results.length > 0" class="columns search-grid-results">
                        <table>
                            <thead is="grid-header" :headers="filteredFields" :initial-sort="prefs.initialSort"></thead>
                            <tbody>
                                <tr v-for="result in results" v-on:click=wrappedEntryClickHandler(result)>
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
                        <vue-pagination class="ma-pager-new" v-if="pageCount > 1" v-on:page-changed="pageChanged" :page-count="pageCount" :current-page="gridState.currentPage"></vue-pagination>
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
import MaketextMixin from './MaketextMixin.vue'
import GridHeader from './GridHeader.vue'
import AmpelField from './fields/AmpelField.vue'
import UrlField from './fields/UrlField.vue'
import UrlFormatField from './fields/UrlFormatField.vue'
import TextField from './fields/TextField.vue'
import ListField from './fields/ListField.vue'
import BadgesField from './fields/BadgesField.vue'
import DateField from './fields/DateField.vue'
import SolrField from './fields/SolrField.vue'
import ImageField from './fields/ImageField.vue'
import TestGridField from './fields/TestGridField.vue'
import FullTextFilter from './filters/FullTextFilter.vue'
import SelectFilter from './filters/SelectFilter.vue'
import MultiSelectFacet from './facets/MultiSelectFacet.vue'
import SingleSelectFacet from './facets/SingleSelectFacet.vue'
import Select2Facet from './facets/Select2Facet.vue'
import NProgress from 'nprogress'
import ExcelExport from './excel_export/ExcelExport.vue'
import 'nprogress/nprogress.css'
import * as mutations from "../store/mutation-types";
import debounce from 'lodash/debounce';

export default {
    mixins: [MaketextMixin],
    components : {
      GridHeader,
      AmpelField,
      UrlField,
      UrlFormatField,
      TextField,
      ListField,
      BadgesField,
      DateField,
      SolrField,
      ImageField,
      TestGridField,
      FullTextFilter,
      SelectFilter,
      MultiSelectFacet,
      SingleSelectFacet,
      Select2Facet,
      ExcelExport
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
          isGridView: false,
          entryClickHandler: null
       }
    },
    props: ['preferencesSelector','pref'],
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
      applyFiltersDebounce() {
        return debounce(this.applyFilters, 700);
      },
      facets(){
        return this.gridState.facets;
      },
      pageCount: function(){
        return Math.ceil(this.numResults / this.resultsPerPage);
      },
      hasFilters(){
        return this.prefs.filters.length > 0;
      },
      hasExcelExport(){
        return this.prefs.enableExcelExport;
      },
      hasAddons(){
        return (this.prefs.addons &&
                this.prefs.addons.length > 0);
      },
      showTopActionBar: function( ){
        return (this.hasFilters ||
                this.hasExcelExport ||
                this.hasAddons);
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
          initialHideColumn: this.initialHideColumn,
          registerEntryClickHandler: this.registerEntryClickHandler
        };
      }
    },
    methods: {
      wrappedEntryClickHandler: function(doc){
        if(this.entryClickHandler){
          this.entryClickHandler(doc);
        }
      },
      registerEntryClickHandler(handler){
        this.entryClickHandler = handler;
      },
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
        for(let i=0;i<array.length;i++){
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
        for(let i = 0; i < this.facets.length; i++){
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
        this.isFilterApplied = false;
        for(let i = 0; i < this.facets.length; i++){
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
        this.isFilterApplied = false;
        for(let i = 0; i < this.facets.length; i++){
          if(this.facets[i].isFilter &&
             !this.facets[i].isDefault){
            this.isFilterApplied = true;
            break;
          }
        }
        this.currentPage = 1;
        this.fetchData();
      },
      sortCritsToString: function() {
        let result = "";
        for(let i = 0; i < this.sortCrits.length; i++) {
          result += this.sortCrits[i].field + " " + this.sortCrits[i].order + ",";
        }
        result = result.slice(0,result.length-1); // drop last comma
        return result;
      },
      collectFilterQueries: function(){
        let filterQueries = [];
        for(let i = 0; i < this.facets.length; i++){
          if(this.facets[i].filterQuery)
            filterQueries.push(this.facets[i].filterQuery);
        }
        return filterQueries;
      },
      getSearchQueryRequestParameters(){
        let startpoint  = (this.currentPage - 1) * this.resultsPerPage;
        if(this.request){
            this.request.abort();
        }

        let params = {
          "topic": this.$foswiki.preferences.WEB + "." + this.$foswiki.preferences.TOPIC,
          "q":this.prefs.q,
          "rows":this.resultsPerPage,
          "start": startpoint,
          "facet": true,
          "facet.limit": 5,
          "facet.missing": 'on',
          "facet.sort": "count",
          "fl" : this.prefs.fieldRestriction,
          form: this.prefs.form
        };

        params["facet.field"] = [];
        params["fq"] = this.collectFilterQueries();

        for(let i = 0; i < this.facets.length; i++){
          params["facet.field"].push(this.facets[i].facetField);
          if(!this.facets[i].isFilter)
            params[`f.${this.facets[i].field}.facet.limit`] = this.facets[i].limit;
        }

        if(this.sortCrits !== []){
          params["sort"] = this.sortCritsToString();
        }

        return params;
      },
      fetchData: function(){
        let params = this.getSearchQueryRequestParameters();

        let self = this;
        NProgress.start();
        this.request = this.$ajax({
          type: "POST",
          headers: { 'X-HTTP-Method-Override': 'GET' },
          url: this.$foswiki.getScriptUrl('rest', 'SearchGridPlugin', 'searchproxy'),
          traditional: true,
          data: params
        })
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
        let searchTermKey = `f.${facet.field}.facet.contains`;
        let ignoreCaseKey = `f.${facet.field}.facet.contains.ignoreCase`;
        let params = {
          "q":this.prefs.q,
          "rows": 0,
          "facet": true,
          "facet.field": facet.facetField,
          "facet.offset": offset,
          "facet.limit": facet.limit,
          "facet.missing": 'on',
          "facet.sort": "count",
          form: this.prefs.form
        };

        if(searchTerm !== ""){
          params[searchTermKey] = searchTerm;
          params[ignoreCaseKey] = true;
        }
        params["fq"] = this.collectFilterQueries();

        let self = this;

        this.$ajax({
          type: "POST",
          headers: { 'X-HTTP-Method-Override': 'GET' },
          url: this.$foswiki.getScriptUrl('rest', 'SearchGridPlugin', 'searchproxy'),
          data: params
        })
        .done(function(result){
          result = JSON.parse(result);
          let parsedResult = self.parseFacetResult(facet.field, result.facet_counts.facet_fields[facet.field], result.facet_dsps);
          callback(parsedResult);
        });
      },
      parseFacetResult: function(facetField, facetResult, facetDisplayValues) {
            let facet = [];
            for(let i = 0; i < facetResult.length; i+=2){
                let field = facetResult[i];
                let displayValue = "";
                if(this.prefs.mappings.hasOwnProperty(facetField) && this.prefs.mappings[facetField].hasOwnProperty(field)){
                  displayValue = this.prefs.mappings[facetField][field];
                }
                else if(facetDisplayValues.hasOwnProperty(facetField) && facetDisplayValues[facetField].hasOwnProperty(field))
                  displayValue = facetDisplayValues[facetField][field];
                else
                  displayValue = field;

                //'__none__ ' is used for empty fields
                if(!field){
                  field = '__none__';
                  displayValue = this.$foswiki.jsi18n.get('SearchGrid', 'None');
                }

                //Remove empty/whitespace entries to not feel broken
                if(field.match(/^\s*$/))
                  continue;

                facet.push({
                  'title': displayValue,
                  'count': facetResult[i+1],
                  'field': field
                });
        }
        facet.sort((a, b) => {
          return a.title.localeCompare(b.title);
        });
        return facet;
      },
      parseAllFacetResults: function(result){
        if(result.facet_counts){
          let parsedFacetValues = {};
          let facetValues = result.facet_counts.facet_fields;
          for (let key in facetValues) {
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
      this.prefs = Vue.getConfigById(this.preferencesSelector);
      if(this.prefs.result.status === 'error') {
        this.results = this.prefs.result;
        return false;
      }
      this.resultsPerPage = this.prefs.resultsPerPage;
      this.numResults = this.prefs.result.response.numFound;
      this.results = this.prefs.result.response.docs;
      this.hasGridView = this.prefs.hasOwnProperty('gridField');
      this.hasLiveFilter = this.prefs.hasLiveFilter;
      this.initialHideColumn = this.prefs.initialHideColumn;
      if(this.prefs.hasOwnProperty("initialSort")){
        let sortCrits = this.prefs.initialSort.split(",");
        let initialSortCrits = [];
        for(let i = 0; i < sortCrits.length; i++) {
          let splitted = sortCrits[i].split(" ");
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

<style lang="scss">
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

.search-grid-top-bar {
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
