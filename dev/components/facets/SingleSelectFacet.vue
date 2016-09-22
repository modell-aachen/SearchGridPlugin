<template>
<div>
    <h2>{{title}}</h2>
    <ul>
        <li><label><input type=radio value="" v-model="selectedFacet">{{maketext("All")}}</label></li>
        <template v-for="value in facetValues[field] | orderBy 'title'">
        <li><label v-show="value.count > 0">
            <input v-show="value.count > 0" type ="radio" value="{{value.field}}" v-model="selectedFacet">
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
            return `{!tag=${this.field} q.op=OR}${this.field}`;
        }
    },
    ready: function () {
        this.$on('reset', function () {
            this.selectedFacet = '';
        });
    }
}
</script>
