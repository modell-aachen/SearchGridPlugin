<template>
    <div class="search-grid-filter flatskin-wrapped">
    <label for="{{id}}">{{params[0]}}</label>
    <input id="{{id}}" v-model="filterText" debounce="500" >
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
      filterQuery: function() {
        if(this.filterText === '')
          return null;
        var field = `{!tag=${this.field} q.op=OR}${this.field}`;
        var queryString = `*${this.filterText}*`
        return `${field}:${queryString}`;
      }
    }
}
</script>

