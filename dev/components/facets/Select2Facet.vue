<template>
<div class="facet">
<h4>{{header}}</h4>
<div class="vue-select-wrapper">
<v-select multiple label="field" :placeholder="maketext('Search term...')" v-model="selectedFacet" :options="options" :on-search="onSearchDebounce" :get-option-label="getOptionLabel" :get-selected-option-label="getSelectedOptionLabel" :prevent-search-filter="true" :on-get-more-options="onGetMoreOptions">
    <template slot="more-results">{{maketext(moreResultsText)}}</template>
</v-select>
</div>
</div>
</template>

<script>
import FacetMixin from './FacetMixin.vue'
import vSelect from "vue-select/src/index.js"
import debounce from 'lodash/debounce';

export default {
    components: {vSelect},
    mixins: [FacetMixin],
    data: function(){
        return {
            options: [],
            moreResultsText: "Show more results"
        };
    },
    computed: {
        header() {
            return `${this.title} (${this.totalCount})`;
        },
        onSearchDebounce(){
            return debounce(this.onSearch, 300);
        }
    },
    watch: {
        facetCharacteristics() {
            this.moreResultsText = "Show more results";
            this.buildOptions(this.facetCharacteristics);
        }
    },
    methods: {
        getOptions: function(search, loading, offset){
            loading(true);
            var self = this;
            this.$parent.fetchFacetCharacteristics(this, search, offset, function(result){
                if(result.length == 0 && offset > 0){
                    self.moreResultsText = "No more results available";
                }
                else{
                    self.moreResultsText = "Show more results";
                    self.buildOptions(result, offset != 0);
                }
                loading(false);
            });
        },
        onSearch: function(search, loading){
            this.getOptions(search, loading, 0);
        },
        onGetMoreOptions: function(search, loading){
            this.getOptions(search, loading, this.options.length);
        },
        getOptionLabel: function(option){
            return option.label;
        },
        getSelectedOptionLabel: function(option){
            return option.title;
        },
        buildOptions: function(facets, append=false){
            var options = [];
            for(var i = 0; i < facets.length; i++){
                var facet = facets[i];
                options.push({
                    label: this.getLabel(facet.title, facet.count),
                    title: facet.title,
                    field: facet.field,
                    count: facet.count
                });
            }
            if(append)
                this.options = this.options.concat(options);
            else
                this.options = options;

            this.options.sort((a, b) => {
                return b.count - a.count;
            });
        }
    },
    created: function () {
        this.$on('reset', function () {
            this.selectedFacet = [];
            this.search = "";
        });
        this.buildOptions(this.facetCharacteristics);
    }
}
</script>

<style lang="sass">
</style>