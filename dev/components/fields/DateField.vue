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
            if(this.params[1]) {
                return moment(date, moment.ISO_8601).fromNow(true);
            }
            return moment(date, moment.ISO_8601).toDate().toLocaleDateString();
        }
    }
}
</script>
