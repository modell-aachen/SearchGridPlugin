<template>
<div class="facet">
    <h4>{{title}}</h4>
    <ul class="facet-list">
        <template v-for="value in facetCharacteristics | orderBy 'title'">
        <li v-show="value.count > 0 || isSelected(value)">
            <input id="{{getCheckboxId(value.field)}}" type ="checkbox" value="{{value.field}}" v-model="selectedCheckboxes">
            <label for="{{getCheckboxId(value.field)}}">
                 {{getLabel(value.title, value.count)}}
            </label>
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
            this.watchSelectedCheckboxes();
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
        getCheckboxId: function(field){
            return `${this.id}-${field}`;
        },
        watchSelectedCheckboxes() {
            this.selectedFacet = [];
            for(var i = 0; i < this.selectedCheckboxes.length; i++){
                var facetKey = this.selectedCheckboxes[i];
                this.selectedFacet.push(this.facetMap[facetKey]);
            }
        }
    },
    beforeCompile: function () {
        this.updateFacetMap();
        this.$on('reset', function () {
            this.selectedCheckboxes = [];
        });
        this.selectedFacetUnwatch();
        this.watchSelectedCheckboxes();
        this.$watch("selectedFacet", function () {
            this.$dispatch("facet-changed");
        });
    }
}
</script>
