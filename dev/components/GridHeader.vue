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
        this.$watch('initialSort', function(){
            this.$broadcast('set-initial-sorting', this.initialSort);
        });
    }
}
</script>
