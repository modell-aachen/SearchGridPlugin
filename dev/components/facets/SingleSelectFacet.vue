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
        this.$on('reset', function () {
            this.selectedFacet = '';
        });
    }
}
</script>
