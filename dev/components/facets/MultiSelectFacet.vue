<template>
<div>
    <h2>{{title}}</h2>
    <ul>
        <template v-for="value in facetValues[field] | orderBy 'title'">
        <li><label v-show="value.count > 0">
            <input type ="checkbox" value="{{value.field}}" v-model="selectedFacet">
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
            return `{!tag=${this.field} q.op=OR}${this.field}`;
        }
    },
    ready: function () {
        this.$on('reset', function () {
            this.selectedFacet = [];
        });
    }
}
</script>
