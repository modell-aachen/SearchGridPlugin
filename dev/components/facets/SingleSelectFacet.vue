<template>
<div>
    <h2>{{params[0]}}</h2>
    <ul>
        <li><label><input type=radio value="" v-model="selectedFacet">All</label></li>
        <template v-for="value in facetValues[params[0]] | orderBy 'title'">
        <li><label v-show="value.count > 0">
            <input v-show="value.count > 0" type ="radio" value="{{value.title}}" v-model="selectedFacet">
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
            selectedFacet: ''
        }
    },
    props: ['params','facetValues'],
    methods: {
        getFacetQuery: function(){
            return this.selectedFacet;
        },
        getFacetField: function(){
            return `{!tag=${this.params[0]} q.op=OR}${this.params[0]}`;
        }
    },
    ready: function () {
        this.$on('reset', function () {
            this.selectedFacet = '';
        });
    }
}
</script>
