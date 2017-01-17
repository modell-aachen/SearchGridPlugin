<template>
<thead>
<tr><th is="grid-header-field" v-for="header in headers" :title="header.title" :sort-field="header.sortField" @sort-click="applySorting"></th></tr>
</thead>
</template>

<script>
import GridHeaderField from './GridHeaderField.vue'
export default {
    props: ['headers', 'initialSort'],
    components: {
        GridHeaderField
    },
    methods: {
        applySorting: function(sortField, sort){
            this.$broadcast('sort-processed');
            this.$dispatch('sort-changed', sortField, sort);
        }
    },
    ready: function() {
        if(typeof this.initialSort !== 'undefined') {
            var field = this.initialSort.split(',')[0].split(' ')[0];
            var sort = this.initialSort.split(',')[0].split(' ')[1];
            this.$broadcast('set-initial-sorting', {field: field, sort: sort});
        }
    }
}
</script>
