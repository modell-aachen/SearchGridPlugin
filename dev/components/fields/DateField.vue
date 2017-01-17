<template>
<td>{{date}}</td>
</template>

<script>
export default {
	/*global moment*/
    props: ['doc','params'],
    computed: {
        date: function(){
            let date = this.doc[this.params[0]];
            if(typeof date === 'undefined')
                return "";
            return moment(date, moment.ISO_8601).toDate().toLocaleDateString();
        }
    }
}
</script>
