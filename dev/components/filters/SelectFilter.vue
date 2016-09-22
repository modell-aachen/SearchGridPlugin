<template>
    <div class="search-grid-filter">
    <label style="display:block;" for="{{id}}">{{params[0]}}</label>
    <select id="{{id}}" v-model="filterValue">
        <option v-bind:value="''">{{maketext('All')}}</option>
        <option v-if="value.count != 0" v-bind:value="value.field" v-for="value in facetValues[this.params[1]]">{{ value.title }} ({{ value.count }})</option>
    </select>
    </div>
</template>

<script>
import MaketextMixin from '../MaketextMixin.vue'
export default {
    mixins: [MaketextMixin],
    props: ['params','facetValues'],
    data:  function () {
       return {
          filterValue: ''
       }
    },
    computed: {
        id: function(){
            return this.params[0] + "_id";
        }
    },
    ready: function () {
        this.$watch("filterValue", function () {
            this.$dispatch("filter-changed",this.filterValue,this.params[1], false);
        });
    },
    created: function () {
        this.$dispatch("register-facet-field",this.params[1]);
    }
}
</script>
