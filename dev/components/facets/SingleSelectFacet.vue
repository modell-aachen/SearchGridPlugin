<template>
<div class="facet">
    <h4>{{title}}</h4>
    <ul class="facet-list">
        <li>
            <input id="{{id('All')}}" type=radio value="" v-model="selectedRadio">
            <label for="{{id('All')}}">{{maketext("All")}}</label>
        </li>
        <template v-for="value in facetCharacteristics | orderBy 'title'">
        <li v-show="value.count > 0 || isSelected(value)">
            <input id="{{id(value.field)}}" type ="radio" value="{{value.field}}" v-model="selectedRadio">
            <label for="{{id(value.field)}}">{{getLabel(value.title, value.count)}}</label>
        </li>
        </template>
    </ul>
</div>
</template>

<script>
var id = -1;

import FacetMixin from './FacetMixin.vue'
export default {
    mixins: [FacetMixin],
    data: function(){
        return {
            selectedFacet: [],
            selectedRadio: ''
        }
    },
    methods: {
        isSelected(value){
            if(this.selectedFacet.length == 0)
                return false;
            return value.field === this.selectedFacet[0].field;
        },
        id: function(field){
            if(id === -1){
                id = Math.random();
                var retValue = this.field + "_" + field + "_facet_" + id;
                return retValue;
            } else {
                var retValue = this.field + "_" + field + "_facet_" + id;
                id = -1;
                return retValue;
            }

        }
    },
    watch: {
        selectedRadio(){
            this.selectedFacet = [];
            if(this.selectedRadio === '')
                return;
            for(var i = 0; i < this.facetCharacteristics.length; i++){
                var currentCharacteristic = this.facetCharacteristics[i];
                if(currentCharacteristic.field === this.selectedRadio){
                    this.selectedFacet.push(currentCharacteristic);
                    console.log(this.selectedFacet);
                    break;
                }
            }
        }
    },
    beforeCompile: function () {
        this.$on('reset', function () {
            this.selectedRadio = '';
        });
    }
}
</script>
