<template>
    <div class="search-grid-filter small-3 columns">
    <label for="{{id}}">{{params[0]}}</label>
    <select id="{{id}}" v-model="selectedOption">
        <option v-bind:value="''">{{maketext('All')}}</option>
        <option v-if="value.count != 0" v-bind:value="value.field" v-for="value in facetValues[this.params[1]]">{{ value.title }} {{'(' + value.count + ')'}}</option>
    </select>
    </div>
</template>

<script>
import MaketextMixin from '../MaketextMixin.vue'
import FacetMixin from '../facets/FacetMixin.vue'
export default {
    mixins: [MaketextMixin,FacetMixin],
    data:  function () {
       return {
          selectedOption: this.params.length > 2 ? this.params[2] : ''
       }
    },
    computed: {
        id: function(){
            return this.params[0] + "_filter";
        },
        totalCount: function(){
            return "";
        },
        isDefault: function(){
            return this.selectedOption === '';
        },
        limit: function(){
            return -1;
        }
    },
    methods: {
        watchSelectedOption() {
            this.selectedFacet = [];
            if(this.selectedOption === '')
                return;
            for(var i = 0; i < this.facetCharacteristics.length; i++){
                var currentCharacteristic = this.facetCharacteristics[i];
                if(currentCharacteristic.field === this.selectedOption){
                    this.selectedFacet.push(currentCharacteristic);
                    break;
                }
            }
        }
    },
    watch: {
        selectedOption() {
            this.watchSelectedOption();
        }
    },
    beforeCompile: function(){
        this.selectedFacetUnwatch();
        this.$on('clear-filters', function () {
            this.selectedOption = '';
        });
        this.watchSelectedOption();
    }
}
</script>
