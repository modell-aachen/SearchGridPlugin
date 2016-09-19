<template>
<div>
	<p>{{params[0]}}</p>
    <input type=radio id="{{params[0] + '_all'}}" value="" v-model="selectedFacet">
    <label for="{{params[0] + '_all'}}">All</label>
	<template v-for="value in facetValues[params[0]] | orderBy 'title'">
		<input v-show="value.count > 0" type ="radio" id="{{value.title + '_id'}}" value="{{value.title}}" v-model="selectedFacet">
		<label v-show="value.count > 0" for="{{value.title + '_id'}}">{{getLabel(value.title, value.count)}}</label>
	</template>
</div>
</template>

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
            this.$dispatch("filter-changed",this.selectedFacet,`{!tag=${this.params[0]} q.op=OR}${this.params[0]}`);
        });
    }
}
</script>
