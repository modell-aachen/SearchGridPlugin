<template>
<div>
    <h2>{{title}}</h2>
    <ul>
        <template v-for="value in facetCharacteristics | orderBy 'title'">
        <li v-show="value.count > 0"><label>
            <input type ="checkbox" value="{{value.field}}" v-model="selectedCheckboxes">
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
