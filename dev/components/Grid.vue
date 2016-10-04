<template>
<div id="cssload-wrapper">
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
  <div class="searchGridResults">
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
        }

        if(this.sortField !== ""){
          params["sort"] = "" + this.sortField + " " + this.sort;
        }
        $.ajaxSettings.traditional = true;
        NProgress.configure({
          parent: '#cssload-wrapper'
        });
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
          self.request = null;
        });
      },
      fetchFacetCharacteristics: function(field, facetField, searchTerm, offset, callback){
        var searchTermKey = `f.${field}.facet.contains`;
        var ignoreCaseKey = `f.${field}.facet.contains.ignoreCase`;
        var params = {
          "q":this.prefs.q,
          "rows": 0,
          "facet": true,
          "facet.field": facetField,
          "facet.offset": offset,
          "facet.limit": 5,
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
          var parsedResult = self.parseFacetResult(field, result.facet_counts.facet_fields[field], result.facet_dsps);
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
    }
}
</script>

<style lang="sass">
.search-grid{
  @import '../../node_modules/foundation-sites/scss/foundation';
@import '../../../FlatSkinPlugin/dev/sass/settings';
@include foundation-global-styles;
@include foundation-flex-classes;
@include foundation-flex-grid;
@include foundation-callout;
@include foundation-forms;
@include foundation-menu;
@include foundation-dropdown;
@include foundation-dropdown-menu;
@include foundation-visibility-classes;
@include foundation-float-classes;
@include foundation-badge;
  @import '../../../FlatSkinPlugin/dev/sass/qwiki/mixins';
  @import '../../../FlatSkinPlugin/dev/sass/qwiki/base';
  @import '../../../FlatSkinPlugin/dev/sass/qwiki/table';
  @import '../../../FlatSkinPlugin/dev/sass/qwiki/paginator';
  .ma-table {
    width:100%;
  }
}
/*------------ facets --------*/
.searchGridResults {
  width: 100%;
  display: inline-block;
}

/*--------merely copied from tablesorter* --------------*/
/*Original doesnt work due to conflicts with vue*/
// table.tablesortercopy {
//   margin:10px 0pt 15px;
//   width: 100%;
//   text-align: left;
// }

// table.tablesortercopy thead tr th,
// table.tablesortercopy tfoot tr th {
//   background-color: #fff;
//   color: #999;
//   text-align: left;
//   padding: 4px 20px 8px 4px;
//   vertical-align: middle;
// }

// table.tablesortercopy.Modac_Standard thead tr th,
// table.tablesortercopy.Modac_Standard tfoot tr th {
//   background-color: #003c89;
//   color: #fff;
//   padding: 0 3px;
//   text-align: center;
// }

// table.tablesortercopy tbody td {
//   color: #3d3d3d;
//   background-color: #fff;
//   margin: 8px 1px;
//   padding: 8px;
//   background: #f8fcff;
// }

// table.tablesortercopy.Modac_Standard tbody td {
//   background: #f9f9f9;
//   padding: 0 3px;
// }

// table.tablesortercopy tbody tr.odd td {
//   background-color:#f8fcff;
// }

// table.tablesortercopy thead tr .sorted {
//   background-color: #fff;
//   color: #000;
//   font-weight: bold;
// }
// table.tablesortercopy thead tr .sortable {
//   cursor: pointer;
// }

// table.tablesortercopy tr.even:hover td,
// table.tablesortercopy tr.odd:hover td {
//   background-color: #e8f7ff;
//   margin: 8px 1px;
//   padding: 8px;
// }

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
