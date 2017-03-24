<template>
    <div class="search-grid-filter fullt-text-filter small-3 columns">
    <label v-bind:for="id">{{params[0]}}</label>
    <div class="input-group">
      <span class="input-group-label"><i class="fa fa-search" aria-hidden="true"></i></span>
      <input class="input-group-field" type="text" v-bind:placeholder="maketext('Search term...')" v-bind:id="id" v-model="filterText">
    </div>
    </div>
</template>

<script>
import FacetMixin from '../facets/FacetMixin.vue'
export default {
    mixins: [FacetMixin],
    data:  function () {
       return {
          filterText: '',
          isFilter: true
       }
    },
    computed: {
      totalCount: function(){
        return "";
      },
      isDefault: function() {
        return this.filterText === '';
      },
      limit: function() {
        return -1;
      },
      filterQuery: function() {
        if(this.filterText === '')
          return null;
        var queries = "(";
        for(var i = 1; i < this.params.length; i++) {
          var currentField = this.params[i];
          var field = `{!tag=${currentField} q.op=OR}${currentField}`;
          var queryString = `*${this.filterText}*`
          queries += `${field}:${queryString}`;
          if(i != this.params.length - 1)
            queries += " OR ";
        }
        queries += ')';
        return queries;
      }
    },
    methods: {
      reset() {
        this.filterText = "";
      }
    }
}
</script>

