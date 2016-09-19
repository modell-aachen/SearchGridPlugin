<template>
<div>
	<p>{{params[0]}}</p>
	<template v-for="value in facetValues[params[0]] | orderBy 'title'">
		<input v-show="value.count > 0" type ="checkbox" id="{{value.title + '_id'}}" value="{{value.title}}" v-model="selectedFacets">
		<label v-show="value.count > 0" for="{{value.title + '_id'}}">{{getLabel(value.title, value.count)}}</label>
	</template>
</div>
</template>

<script>
export default {
	data: function(){
		return {
			selectedFacets: []
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
        this.$watch("selectedFacets", function () {
        	var queryString = "";
        	if(this.selectedFacets.length > 0){
        		queryString = "(";
	        	for(var i=0; i < this.selectedFacets.length; i++){
	        		queryString += this.selectedFacets[i]
	        		if(i != this.selectedFacets.length - 1)
	        			queryString += " ";
	        	}
	        	queryString += ")";
	        }
            this.$dispatch("filter-changed",queryString,`{!tag=${this.params[0]} q.op=OR}` + this.params[0]);
        });
    }
}
</script>
