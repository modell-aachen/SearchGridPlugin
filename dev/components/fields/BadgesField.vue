<template>
<div>
    <span class="ma-badge" v-for="item in getList()">{{item}}</span>
</div>
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
