<template>
    <div class="flatskin-wrapped">
        <div class="grid-x">
            <!--Toplevel container -->
            <div class="cell">
                <!-- Filters and table -->
                <div v-if="showTopActionBar" class="grid-x align-bottom">
                    <div class="cell small-8 medium-10 large-10">
                        <div class="grid-x">
                            <!-- Filters -->
                            <template v-for="filter in prefs.filters" class="cell shrink">
                                <component v-if="hasLiveFilter" v-on:filter-change="applyFiltersDebounce" v-on:confirm="applyFilters" :is="filter.component" :params="filter.params" :facet-values="facetValues" @facet-changed="facetChanged" @register-facet="registerFacet"></component>
                                <component v-else v-on:confirm="applyFilters" :is="filter.component" :params="filter.params" :facet-values="facetValues" @facet-changed="facetChanged" @register-facet="registerFacet"></component>
                            </template>
                            <vue-spacer
                                factor-horizontal="3"/>
                            <div v-if="hasFilters" class="cell shrink align-self-bottom">
                                <vue-button type='icon' icon='fas fa-filter' @click.native='applyFilters' />
                            </div>
                            <div v-if="hasAddons" class="cell shrink">
                              <template v-for="addon in prefs.addons">
                                <component :is="addon" :api="api">
                                </component>
                              </template>
                            </div>
                            <div v-if="hasExcelExport" class="cell shrink">
                              <div class="">
                                <excel-export :fields="prefs.fields"></excel-export>
                              </div>
                            </div>
                            <div v-if="hasGridView" class="cell shrink">
                                <div class="grid-toggle ">
                                    <vue-button v-bind:class="{disabled: isGridView, selected: !isGridView}" type='icon' icon='fa fa-bars'  @click.native="toggleGridView('table')"></vue-button>
                                    <vue-button v-bind:class="{disabled: !isGridView, selected: isGridView}" type='icon' icon='fa fa-th-large'  @click.native="toggleGridView('grid')"></vue-button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="cell small-4 medium-2 large-2 resetFilterButton">
                        <vue-button :is-disabled="!isFilterApplied" :title='maketext("Reset all")' @click.native="clearFacets()"/>
                    </div>
                </div>
                <div class="grid-x">
                    <div class="cell auto">
                        <div class="grid-x searchGridTable" v-bind:class="isGridView ? ['medium-up-1', 'xlarge-up-2', 'xxxlarge-up-3', 'xxxxlarge-up-3'] : []">
                            <!-- Table -->
                            <div class="cell auto" v-if="!wizardConfig || !wizardConfig.component" v-show="results.length == 0"><p>{{maketext("No results")}}</p></div>
                            <div class="cell auto ma-bg-beige-color" v-else v-show="wizardConfig.component && results.length == 0">
                              <component class="ma-bg-white-color" :is="wizardConfig.component" :params="wizardConfig.params"></component>
                            </div>
                            <div class="cell auto" v-show="results.status == 'error'"><p>{{maketext(results.msg)}}</p></div>
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
                            <vue-spacer class="cell shrink" v-if="showFacets"
                                factor-horizontal="5"/>
                        </div>
                    </div>
                    <div v-if="showFacets" class="cell small-4 xlarge-3 xxlarge-2">
                        <!-- Facets -->
                        <div class="wrapper">
                            <div>
                                <h3 class="headlineFacets">
                                  {{maketext("Filters")}}
                                </h3>
                                <vue-spacer
                                    factor-vertical="3"/>
                                <template v-for="facet in prefs.facets">
                                    <component :is="facet.component" :params="facet.params" :facet-values="facetValues" @facet-changed="facetChanged" :facet-total-counts="prefs.result.facetTotalCounts" @get-facet-info="fetchFacetCharacteristics" @register-facet="registerFacet"/>
                                </template>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="grid-x">
                    <div class="cell">
                        <vue-pagination v-if="pageCount > 1" @input="pageChanged" :page-count="pageCount" v-model="gridState.currentPage"></vue-pagination>
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
import UserField from './fields/UserField.vue'
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
      UserField,
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
          entryClickHandler: null,
          wizardConfig: null,
          wizardNoResultsConfig: null
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
      hasFacets(){
        return this.prefs.facets.length > 0;
      },
      hasExcelExport(){
        return this.prefs.enableExcelExport;
      },
      hasAddons(){
        return (this.prefs.addons &&
                this.prefs.addons.length > 0);
      },
      showTopActionBar: function( ){
        return (
            this.isFilterApplied || this.results.length > 0 && (
            this.hasFilters ||
            this.hasExcelExport ||
            this.hasAddons)
        );
      },
      showFacets: function(){
        return (this.results.length > 0 || this.isFilterApplied) && this.prefs.facets.length > 0;
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
        if(this.isFilterApplied){
          this.isFilterApplied = false;
          for(let i = 0; i < this.facets.length; i++){
            this.facets[i].reset();
          }
          this.$nextTick(function(){
            this.fetchData();
          });
        }
      },
      applyFilters: function(){
        for(let i = 0; i < this.facets.length; i++){
          if(this.facets[i].isFilter &&
             !this.facets[i].isDefault){
            break;
          }
        }
        this.currentPage = 1;
        this.wizardConfig = this.wizardNoResultsConfig;
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
        this.isFilterApplied = false;
        let filterQueries = [];
        for(let i = 0; i < this.facets.length; i++){
          if(this.facets[i].filterQuery){
            this.isFilterApplied = true;
            filterQueries.push(this.facets[i].filterQuery);
          }
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
          "facet.limit": -1,
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
          "facet.sort": "count",
          form: this.prefs.form
        };

        if(searchTerm !== ""){
          params[searchTermKey] = searchTerm;
          params[ignoreCaseKey] = true;
        }else{
          params['facet.missing'] = 'on';
        }
        params["fq"] = this.collectFilterQueries();

        let self = this;

        this.$ajax({
          type: "POST",
          headers: { 'X-HTTP-Method-Override': 'GET' },
          url: this.$foswiki.getScriptUrl('rest', 'SearchGridPlugin', 'searchproxy'),
          data: params,
          traditional: true,
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
                } else if(facetDisplayValues.hasOwnProperty(facetField) && facetDisplayValues[facetField].hasOwnProperty(field)) {
                  displayValue = facetDisplayValues[facetField][field];
                } else {
                  displayValue = field;
                }

                //'__none__ ' is used for empty fields
                if(!field && facetField){
                  field = '__none__';
                  displayValue = this.maketext('None');
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
        // sort facet-options; 'None' should be the last element
        facet.sort((a, b) => {
          if(a.field == '__none__'){
            return 1;
          }
          if(b.field == '__none__'){
            return -1;
          }
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
      this.wizardConfig = this.prefs.wizardNoEntriesConfig;
      this.wizardNoResultsConfig = this.prefs.wizardNoResultsConfig;

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
.flatskin-wrapped div.resetFilterButton {
    text-align: right;
    a {
        margin-right: 0px;
    }
}
.searchGridWrapper {
  overflow: auto;
}

.error {
  color: red;
}

h1.facets-header {
  margin: 0px;
}

.searchGridTable {
  clear: both;
}

.search-grid-top-filter {
  width: 262px;
}

h3.headlineFacets{
  margin-top: 16px;
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
