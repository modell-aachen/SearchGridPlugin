<template>
<thead>
<tr><th is="grid-header-field" v-for="header in headers" :title="header.title" :sort-field="header.sortField" @sort-click="applySorting"></th></tr>
</thead>
</template>

<script>
import GridComponentMixin from "./GridComponentMixin.vue";
import GridHeaderField from './GridHeaderField.vue'
export default {
    mixins: [GridComponentMixin],
    props: ['headers', 'initialSort'],
    components: {
        GridHeaderField
    },
    methods: {
        applySorting: function(sortField, sort){
            //TODO this.DOLLARbroadcast('sort-processed');
            //TODO this.DOLLARdispatch('sort-changed', sortField, sort);
        }
    },
    mounted: function() {
        if(typeof this.initialSort !== 'undefined') {
            var field = this.initialSort.split(',')[0].split(' ')[0];
            var sort = this.initialSort.split(',')[0].split(' ')[1];
            //TODO this.DOLLARbroadcast('set-initial-sorting', {field: field, sort: sort});
        }
    }
}
</script>
