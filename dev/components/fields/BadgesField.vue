<template>
    <td>
        <span class="ma-badge" v-for="(item, index) in getList()" :key="index">{{item}}</span>
    </td>
</template>

<script>
export default {
    props: ['doc','params'],
    computed: {
        field() {
            return this.params[0];
        }
    },
    methods: {
        getList: function() {
            return this.doc[this.field];
        }
    }
}
</script>
