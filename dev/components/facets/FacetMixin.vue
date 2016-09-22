<script>
export default {
	data: function(){
		return {
			selectedFacet: ''
		}
	},
    props: ['params','facetValues'],
    computed: {
        title: function(){
            return this.params[0];
        },
        field: function(){
            return this.params[1];
        }
    },
    methods: {
    	getLabel: function(value, count){
    		return value + " (" + count + ")";
    	}
    },
    ready: function () {
        this.$dispatch("register-facet-field","{!ex=" + this.field + "}" + this.field);
        this.$watch("selectedFacet", function () {
            this.$dispatch("filter-changed",this.getFacetQuery(),this.getFacetField());
        });
    }
}
</script>
