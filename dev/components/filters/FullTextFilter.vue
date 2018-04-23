<template>
    <div class="">
    <!-- <div class="search-grid-filter fullt-text-filter small-3 columns"> -->
      <vue-input-text :label="params[0]" v-on:keyup.enter="onConfirm" icon="fa fa-search" :placeholder="maketext('Search term...')" :id="id" v-model="filterText">
      </vue-input-text>
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
        let queries = "(";
        let words = this.filterText.trim().split(" ");
        for(let w = 0; w < words.length; w++) {
            queries += '(';
            for(let i = 1; i < this.params.length; i++) {
              let currentField = this.params[i];
              let queryString = `*${words[w]}*`;
              queries += `${currentField}:${queryString}`;
              if(i != this.params.length - 1)
                queries += " OR ";
            }
            queries += ')';
            if(w != words.length - 1)
                queries += " AND ";
        }
        queries += ')';
        return queries;
      }
    },
    watch: {
      filterText(){
        this.$emit("filter-change");
      }
    },
    methods: {
      reset() {
        this.filterText = "";
      },
      onConfirm() {
        this.$emit("confirm");
      }
    }
}
</script>

