<template>
    <td>
        <template v-for="item in getList()">{{item}}<br></template>
    </td>
</template>

<script>
export default {
    props: ['doc','params'],
    computed: {
        field() {
            return this.params[0];
        },
        separateBySpace() {
            return this.params[1];
        }
    },
    methods: {
        getList: function() {
            if(this.separateBySpace){
                return [this.doc[this.field].join(" ")];
            }
            else{
                return this.doc[this.field];
            }
        }
    }
}
</script>
