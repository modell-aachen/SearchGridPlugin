<template>
<div class="facet">
    <h4>{{title}}</h4>
    <ul class="facet-list">
        <li>
            <input id="{{getRadioId('All')}}" type=radio value="" v-model="selectedRadio">
            <label for="{{getRadioId('All')}}">{{maketext("All")}}</label>
        </li>
        <template v-for="value in facetCharacteristics | orderBy 'title'">
        <li v-show="value.count > 0 || isSelected(value)">
            <input id="{{getRadioId(value.field)}}" type ="radio" value="{{value.field}}" v-model="selectedRadio">
            <label for="{{getRadioId(value.field)}}">{{getLabel(value.title, value.count)}}</label>
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
        getRadioId: function(field){
            return `${this.id}-${field}`;
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
                    break;
                }
            }
        }
    },
    beforeCompile: function () {
        this.$on('reset', function () {
            this.selectedRadio = '';
        });
        // Check if an inital value for this facet has been configured
        if(this.params.length > 3) {
            this.selectedRadio = this.params[3];
        }
    }
}
</script>
