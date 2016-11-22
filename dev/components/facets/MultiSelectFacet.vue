<template>
<div class="facet">
    <h4>{{title}}</h4>
    <ul class="facet-list">
        <template v-for="value in facetCharacteristics | orderBy 'title'">
        <li v-show="value.count > 0 || isSelected(value)">
            <input id="{{id(value.field)}}" type ="checkbox" value="{{value.field}}" v-model="selectedCheckboxes">
            <label for="{{id(value.field)}}">
                 {{getLabel(value.title, value.count)}}
            </label>
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
            selectedCheckboxes: [],
            facetMap: {}
		}
	},
    watch: {
        selectedCheckboxes() {
            this.selectedFacet = [];
            for(var i = 0; i < this.selectedCheckboxes.length; i++){
                var facetKey = this.selectedCheckboxes[i];
                this.selectedFacet.push(this.facetMap[facetKey]);
            }
        },
        facetCharacteristics(){
            this.updateFacetMap();
        }
    },
    methods: {
        updateFacetMap(){
            this.facetMap = {};
            for(var i = 0; i < this.facetCharacteristics.length; i++){
                var currentCharacteristic = this.facetCharacteristics[i];
                this.facetMap[currentCharacteristic.field] = currentCharacteristic;
            }
        },
        isSelected(value){
            if(this.selectedFacet.length == 0)
                return false;
            for(var i = 0; i < this.selectedFacet.length; i++){
                if(this.selectedFacet[i].field === value.field)
                    return true;
            }
            return false;
        },
         id: function(field){
            var retValue;
            if(id === -1){
                id = Math.random();
                retValue = this.field + "_" + field + "_facet_" + id;
                return retValue;
            } else {
                retValue = this.field + "_" + field + "_facet_" + id;
                id = -1;
                return retValue;
            }

        }
    },
    beforeCompile: function () {
        this.updateFacetMap();
        this.$on('reset', function () {
            this.selectedCheckboxes = [];
        });
    }
}
</script>
