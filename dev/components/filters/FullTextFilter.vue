<template>
    <div class="search-grid-filter columns shrink">
    <label for="{{id}}">{{params[0]}}</label>
    <div class="input-group">
      <span class="input-group-label"><i class="fa fa-search" aria-hidden="true"></i></span>
      <input class="input-group-field" type="text" id="{{id}}" v-model="filterText" debounce="500" >
    </div>
    </div>
</template>

<script>
import FacetMixin from '../facets/FacetMixin.vue'
export default {
    mixins: [FacetMixin],
    data:  function () {
       return {
          filterText: ''
       }
    },
    computed: {
      id: function(){
        return this.params[0] + "_filter";
      },
      totalCount: function(){
        return "";
      },
      isDefault: function() {
        return this.filterText === '';
      },
      filterQuery: function() {
        if(this.filterText === '')
          return null;
        var field = `{!tag=${this.field} q.op=OR}${this.field}`;
        var queryString = `*${this.filterText}*`
        return `${field}:${queryString}`;
      }
    },
    beforeCompile: function(){
      this.$on('clear-filters', function () {
          this.filterText = '';
      });
  }
}
</script>

