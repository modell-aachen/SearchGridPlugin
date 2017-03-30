<template>
<thead>
<tr><th is="grid-header-field" v-for="header in headers" :title="header.title" :sort-field="header.sortField"></th></tr>
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
    }
}
</script>
