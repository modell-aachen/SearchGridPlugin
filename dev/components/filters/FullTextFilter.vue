<template>
    <div class="filter">
    <label for="{{id}}">{{params[0]}}</label>
    <input id="{{id}}" v-model="filterText" debounce="500">
    </div>
</template>

<script>
export default {
    props: ['params'],
    data:  function () {
       return {
          filterText: ''
       }
    },
    computed: {
      id: function(){
        return this.params[0] + "_id";
      }
    },
    ready: function () {
        this.$watch("filterText", function () {
            this.$dispatch("filter-changed","*" + this.filterText + "*",this.params[1]);
        });
    }
}
</script>

<style>
.filter {
  float: left;
  margin-right: 10px;
}
.filter label,input,select {
  display:block;
}
</style>