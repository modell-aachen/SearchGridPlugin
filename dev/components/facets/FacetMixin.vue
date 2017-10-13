<script>
import GridComponentMixin from "../GridComponentMixin.vue";
import MaketextMixin from "../MaketextMixin.vue"
import * as mutations from "../../store/mutation-types";
export default {
    mixins: [GridComponentMixin,MaketextMixin],
    data: function(){
        return {
            selectedFacet: [],
            selectedFacetUnwatch: null
        }
    },
    props: ['params','facetValues','facetTotalCounts'],
    computed: {
        id(){
            return Math.random().toString(36).substring(7);
        },
        title: function(){
            return this.params[0];
        },
        field: function(){
            return this.params[1];
        },
        limit: function(){
            if(this.params.length >= 3){
                return this.params[2];
            }
            else
                return -1;
        },
        // Used as facet.field in solr queries.
        facetField: function(){
            return `{!ex=${this.field}}${this.field}`;
        },
        totalCount: function(){
            return this.facetTotalCounts[this.field];
        },
        filterQuery: function(){
            let field = `{!tag=${this.field} q.op=OR}${this.field}`;
            let queryString = "";
            if(this.selectedFacet.length > 0){
                for(let i=0; i < this.selectedFacet.length; i++){
                    queryString += this.escapeSolrQuery(this.selectedFacet[i].field);
                    if(i != this.selectedFacet.length - 1)
                        queryString += " ";
                }

                //'__none__ ' is used for empty fields
                if(queryString == '__none__'){
                    queryString = `(-${this.field}:["" TO *])`;
                }else{
                    queryString = "(" + queryString + ")";
                }

            }
            else
                return null;
            return `${field}:${queryString}`;
        },
        facetCharacteristics: function(){
            return this.facetValues[this.field];
        }
    },
    methods: {
        getLabel: function(value, count){
            return value + " (" + count + ")";
        },
        escapeSolrQuery: function(string){
            return string.replace(/\+|-|:|\(|\)|\|\||&&|!|"|\s/g, function(finding){
                return `\\${finding}`;
            });
        },
        reset: function(){
            this.selectedFacet = [];
        }
    },
    mounted: function () {
        this.$store.commit("searchGrid/" + mutations.REGISTER_FACET, {gridState: this.gridState, facet: this});
        this.selectedFacetUnwatch = this.$watch("selectedFacet", function () {
            this.$parent.facetChanged();
        });
    }
}
</script>

<style lang="scss">
.facet {
    .facet-list {
        list-style: none !important;
        padding: 0px;
        li {
            margin-bottom: 5px;
        }
    }
}
</style>
