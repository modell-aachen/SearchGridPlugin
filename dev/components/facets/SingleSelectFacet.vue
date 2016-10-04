<template>
<div>
    <h2>{{title}}</h2>
    <ul>
        <li><label><input type=radio value="" v-model="selectedRadio">{{maketext("All")}}</label></li>
        <template v-for="value in facetCharacteristics | orderBy 'title'">
        <li v-show="value.count > 0"><label>
            <input type ="radio" value="{{value.field}}" v-model="selectedRadio">
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
            selectedFacet: [],
            selectedRadio: ''
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
    }
}
</script>
