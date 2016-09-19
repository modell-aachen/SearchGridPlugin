<template>
    <select v-model="filterValue">
        <option v-bind:value="''"></option>
        <option v-if="value.count != 0" v-bind:value="value.title" v-for="value in facetValues[this.params[1]]">{{ value.title }} ({{ value.count }})</option>
    </select>
</template>

<script>
export default {
    props: ['params','facetValues'],
    data:  function () {
       return {
          filterValue: ''
       }
    },
    ready: function () {
        this.$watch("filterValue", function () {
            this.$dispatch("filter-changed",this.filterValue,this.params[1]);
        });
    },
    created: function () {
        this.$dispatch("register-facet-field",this.params[1]);
    }
}
</script>
