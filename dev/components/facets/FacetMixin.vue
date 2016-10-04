<script>
import MaketextMixin from "../MaketextMixin.vue"
export default {
    mixins: [MaketextMixin],
	data: function(){
		return {
			selectedFacet: []
		}
	},
    props: ['params','facetValues','facetTotalCounts'],
    computed: {
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
            var field = `{!tag=${this.field} q.op=OR}${this.field}`;
            var queryString = "";
            if(this.selectedFacet.length > 0){
                for(var i=0; i < this.selectedFacet.length; i++){
                    queryString += this.selectedFacet[i].field;
                    if(i != this.selectedFacet.length - 1)
                        queryString += " ";
                }
                queryString = "(" + this.escapeSolrQuery(queryString) + ")";

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
            return string.replace(/\+|-|:|\(|\)|\|\||&&|\!|\"/g, function(finding){
                return `\\${finding}`;
            });
        }
    },
    beforeCompile: function () {
        this.$dispatch("register-facet",this);
        this.$watch("selectedFacet", function () {
            this.$dispatch("facet-changed");
        });
    }
}
</script>

<style lang="sass">
.facet {
    .facet-list {
        list-style: none !important;
        padding: 0px;
    }
}
</style>