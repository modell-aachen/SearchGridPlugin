<script>
export default {
	data: function(){
		return {
			selectedFacet: ''
		}
	},
    props: ['params','facetValues'],
    methods: {
    	getLabel: function(value, count){
    		return value + " (" + count + ")";
    	}
    },
    ready: function () {
        this.$dispatch("register-facet-field","{!ex=" + this.params[0] + "}" + this.params[0]);
        this.$watch("selectedFacet", function () {
            this.$dispatch("filter-changed",this.getFacetQuery(),this.getFacetField());
        });
    }
}
</script>
