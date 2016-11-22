<template>
<td>{{date}}</td>
</template>

<script>
export default {
	/*global moment:true*/
    props: ['doc','params'],
    computed: {
        date: function(){
            return moment(this.doc[this.params[0]], moment.ISO_8601).toDate().toLocaleDateString();
        }
    }
}
</script>
