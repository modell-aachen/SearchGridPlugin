<template>
<input v-model="filterText" debounce="500">
</template>

<script>
export default {
    props: ['params'],
    data:  function () {
       return {
          filterText: ''
       }
    },
    ready: function () {
        this.$watch("filterText", function () {
            this.$dispatch("filter-changed","*" + this.filterText + "*",this.params[0]);
        });
    }
}
</script>
