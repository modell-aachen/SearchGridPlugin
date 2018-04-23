<template>
<div class="facet">
    <h4>{{title}}</h4>
    <ul class="facet-list">
        <template v-for="value in facetCharacteristics">
            <li v-show="value.count > 0 || isSelected(value)">
                <vue-check-item :value="value.field" v-model="selectedCheckboxes">{{getLabel(value.title, value.count)}}</vue-check-item>
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
            selectedCheckboxes: this.params.length > 3 ? this.params[3].split(";") : [],
            facetMap: {}
		}
	},
    watch: {
        selectedCheckboxes() {
            this.updateSelectedFacets();
        },
        facetCharacteristics(){
            this.updateFacetMap();
        }
    },
    methods: {
        updateFacetMap(){
            this.facetMap = {};
            for(let i = 0; i < this.facetCharacteristics.length; i++){
                let currentCharacteristic = this.facetCharacteristics[i];
                this.facetMap[currentCharacteristic.field] = currentCharacteristic;
            }
        },
        isSelected(value){
            if(this.selectedFacet.length == 0)
                return false;
            for(let i = 0; i < this.selectedFacet.length; i++){
                if(this.selectedFacet[i].field === value.field)
                    return true;
            }
            return false;
        },
        getCheckboxId: function(field){
            return `${this.id}-${field}`;
        },
        updateSelectedFacets() {
            this.selectedFacet = [];
            for(let i = 0; i < this.selectedCheckboxes.length; i++){
                let facetKey = this.selectedCheckboxes[i];
                this.selectedFacet.push(this.facetMap[facetKey]);
            }
        },
        reset() {
            this.selectedCheckboxes = [];
        }
    },
    created: function () {
        this.updateFacetMap();
        this.updateSelectedFacets();
    }
}
</script>
