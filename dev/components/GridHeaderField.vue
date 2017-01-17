<template>
<th v-if="sortField !== 'none'" v-on:click="toggleSort" :class="{'sorted': sortingEnabled, 'sortable':true}">
    {{title}}
    <i v-show="sortingEnabled" class="fa fa-caret-{{sortingIconClass}}" aria-hidden="true"></i>
    <i v-else class="fa fa-sort" aria-hidden="true"></i>
</th>
<th v-else>{{title}}</th>
</template>

<script>
var sortStates = {
    NONE: 0,
    ASC: 1,
    DESC: 2
};
export default {
    data: function(){
        return {
            sortState : sortStates["NONE"],
            triggeredSort: false
        }
    },
    props: ['title','sortField'],
    computed: {
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
            if(this.sortField === 'none')
                return;
            var sort;
            switch(this.sortState){
                case sortStates["NONE"]:
                    this.sortState = sortStates["ASC"];
                    sort = "asc";
                    break;
                case sortStates["DESC"]:
                    this.sortState = sortStates["ASC"];
                    sort = "asc";
                    break;
                case sortStates["ASC"]:
                    this.sortState = sortStates["DESC"];
                    sort = "desc";
                    break;
            }
            this.triggeredSort = true;
            this.$dispatch('sort-click', this.sortField, sort);
        }
    },
    events: {
        "sort-processed": function(){
            if(!this.triggeredSort)
                this.sortState = sortStates["NONE"];
            this.triggeredSort = false;
        },
        "set-initial-sorting": function(initialSorting) {
            if(initialSorting.field === this.sortField){
                this.sortState = sortStates[initialSorting.sort.toUpperCase()];
            }
        }
    },
    ready: function() {
        if(! this.sortField){
            this.sortField = "none";
        }
    }
}
</script>

<style lang="sass">
.sortable {
    cursor: pointer;
}
</style>