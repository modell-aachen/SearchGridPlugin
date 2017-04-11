<template>
    <td>
        <template v-for="item in getList()">{{item}}<br></template></td>
</template>

<script>
export default {
    props: ['doc','params'],
    methods: {
        getList: function() {
            return this.doc[this.params[0]]
        }
    }
}
</script>
