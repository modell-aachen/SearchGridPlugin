<template>
<th v-if="sortField !== 'none'" v-on:click="toggleSort" :class="{'sorted': sortingEnabled, 'sortable':true}">
    {{title}}
    <i v-if="sortingEnabled" v-bind:class="'fa fa-caret-' + sortingIconClass" aria-hidden="true"></i>
    <i v-else class="fa fa-sort" aria-hidden="true"></i>
</th>
<th v-else>{{title}}</th>
</template>

<script>
import GridComponentMixin from "./GridComponentMixin.vue";
import * as mutations from "../store/mutation-types";
var sortStates = {
    NONE: 0,
    ASC: 1,
    DESC: 2
};
export default {
    mixins: [GridComponentMixin],
    props: ['title','sortField'],
    computed: {
        sortState() {
            if(this.gridState.sortCrits.length != 1)
                return sortStates["NONE"];
            let sortCrits = this.gridState.sortCrits[0];
            if(sortCrits.field === this.sortField){
                return sortStates[sortCrits.order.toUpperCase()];
            }
            else{
                return sortStates["NONE"];
            }
        },
        sortingEnabled: function(){
            return this.sortState != sortStates["NONE"];
        },
        sortingIconClass: function(){
            switch(this.sortState){
                case sortStates["NONE"]:
                case sortStates["ASC"]:
                    return "up";
                case sortStates["DESC"]:
                    return "down";
            }
        }
    },
    methods: {
        toggleSort: function(){
            if(!this.sortField)
                return;
            var sort;
            switch(this.sortState){
                case sortStates["NONE"]:
                    sort = "asc";
                    break;
                case sortStates["DESC"]:
                    sort = "asc";
                    break;
                case sortStates["ASC"]:
                    sort = "desc";
                    break;
            }
            this.$store.commit("searchGrid/" + mutations.CHANGE_SORT, {gridState: this.gridState, sortCrits: [{field: this.sortField, order: sort}]});
        }
    }
}
</script>

<style lang="sass">
.sortable {
    cursor: pointer;
}
</style>