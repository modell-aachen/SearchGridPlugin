<template>
<div>
    <h2>{{params[0]}}</h2>
    <ul>
        <template v-for="value in facetValues[params[0]] | orderBy 'title'">
        <li><label v-show="value.count > 0">
            <input type ="checkbox" value="{{value.title}}" v-model="selectedFacet">
            {{getLabel(value.title, value.count)}}
        </label></li>
        </template>
    </ul>
</div>
</template>

<script>
import FacetMixin from './FacetMixin.vue'
export default {
    mixins: [FacetMixin],
	data: function(){
		return {
			selectedFacet: []
		}
	},
    props: ['params','facetValues'],
    methods: {
    	getFacetQuery: function(){
            var queryString = "";
            if(this.selectedFacet.length > 0){
                queryString = "(";
                for(var i=0; i < this.selectedFacet.length; i++){
                    queryString += this.selectedFacet[i]
                    if(i != this.selectedFacet.length - 1)
                        queryString += " ";
                }
                queryString += ")";
            }
            return queryString;
        },
        getFacetField: function(){
            return `{!tag=${this.params[0]} q.op=OR}${this.params[0]}`;
        }
    },
    ready: function () {
        this.$on('reset', function () {
            this.selectedFacet = [];
        });
    }
}
</script>
