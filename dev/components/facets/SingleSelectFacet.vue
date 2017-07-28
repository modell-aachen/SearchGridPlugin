<template>
<div class="facet">
    <h4>{{title}}</h4>
    <ul class="facet-list">
        <li>
            <input v-bind:id="getRadioId('All')" type=radio value="" v-model="selectedRadio">
            <label v-bind:for="getRadioId('All')">{{maketext("All")}}</label>
        </li>
        <template v-for="value in facetCharacteristics">
        <li v-show="value.count > 0 || isSelected(value)">
            <input v-bind:id="getRadioId(value.field)" type ="radio" v-bind:value="value.field" v-model="selectedRadio">
            <label v-bind:for="getRadioId(value.field)">{{getLabel(value.title, value.count)}}</label>
        </li>
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
            selectedRadio: this.params.length > 3 ? this.params[3] : ''
        }
    },
    methods: {
        isSelected(value){
            if(this.selectedFacet.length == 0)
                return false;
            return value.field === this.selectedFacet[0].field;
        },
        getRadioId: function(field){
            return `${this.id}-${field}`;
        },
        updateSelectedFacets() {
            this.selectedFacet = [];
            if(this.selectedRadio === '')
                return;
            for(let i = 0; i < this.facetCharacteristics.length; i++){
                let currentCharacteristic = this.facetCharacteristics[i];
                if(currentCharacteristic.field === this.selectedRadio){
                    this.selectedFacet.push(currentCharacteristic);
                    break;
                }
            }
        },
        reset() {
            this.selectedRadio = "";
        }
    },
    watch: {
        selectedRadio(){
            this.updateSelectedFacets();
        }
    },
    created: function () {
        this.updateSelectedFacets();
    }
}
</script>
