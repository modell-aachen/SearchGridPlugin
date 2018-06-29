<template>
    <div class="facet">
        <label>{{header}}</label>
        <div class="facet-select2">
            <vue-select
                multiple
                is-small
                :placeholder="maketext('Search term...')"
                :sort-slot-options="false"
                v-model="selectedFacet"
                :initial-options="options"
                :on-search="onSearchDebounce"
                :get-option-label="getOptionLabel"
                :get-selected-option-label="getSelectedOptionLabel"
                :prevent-search-filter="true"
                :on-get-more-options="onGetMoreOptions"
            >
                <template slot="more-results">{{maketext(moreResultsText)}}</template>
            </vue-select>
        </div>
    </div>
</template>

<script>
import FacetMixin from './FacetMixin.vue'
import debounce from 'lodash/debounce';

const ShowMoreResultsString = "Show more results";
const NoMoreResultsString = "No more results available";

export default {
    mixins: [FacetMixin],
    data: function(){
        return {
            options: [],
            moreResultsText: ShowMoreResultsString,
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
            this.moreResultsText = ShowMoreResultsString;
            this.buildOptions(this.facetCharacteristics);
        }
    },
    methods: {
        getOptions: function(search, loading, offset){
            loading(true);
            let self = this;
            this.$parent.fetchFacetCharacteristics(this, search, offset, function(result){
                self.buildOptions(result, offset != 0);
                loading(false);
            });
        },
        onSearch: function(search, loading){
            this.getOptions(search, loading, 0);
        },
        onGetMoreOptions: function(search, loading){
            let offset = this.options.length;
            if(offset && this.options[0].field === '__none__') { // XXX guesswork
                offset--;
            }
            this.getOptions(search, loading, offset);
        },
        getOptionLabel: function(option){
            return option.label;
        },
        getSelectedOptionLabel: function(option){
            return option.title;
        },
        buildOptions: function(facets, append=false){
            let options = [];
            for(let i = 0; i < facets.length; i++){
                let facet = facets[i];
                if(facet.field == '__none__'){
                    if(append && this.options && this.options[0] && this.options[0].field == '__none__') {
                        // there already is a 'None' option
                    } else {
                        // sort facet option 'None' to top
                        if(facet.count) {
                            options.unshift({
                                label: this.getLabel(facet.title, facet.count),
                                title: facet.title,
                                value: facet.field,
                                field: facet.field, // required for sorting / finding out if there is a none option
                                count: facet.count
                            });
                        }
                    }
                }else{
                    options.push({
                        label: this.getLabel(facet.title, facet.count),
                        title: facet.title,
                        value: facet.field,
                        count: facet.count
                    });
                }
            }
            if(append)
                this.options = this.options.concat(options);
            else
                this.options = options;

            this.options.sort((a, b) => { // this SHOULD be a noop
                if(a.field == '__none__') {
                    return -1;
                }
                if(b.field == '__none__') {
                    return 1;
                }

                return b.count - a.count;
            });

            if(options.length) { // XXX this requires a request that returns no results (use numTerms)
                this.moreResultsText = ShowMoreResultsString;
            } else {
                this.moreResultsText = NoMoreResultsString;
            }
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

<style lang="scss">
    .facet-select2 {
        margin-top: 8px;
    }
</style>
