<template>
<td>{{date}}</td>
</template>

<script>
import Moment from 'moment'
export default {
    props: ['doc','params'],
    computed: {
        date: function(){
        	console.log(this.doc[this.params[0]]);
            return Moment(this.doc[this.params[0]], Moment.ISO_8601).toDate().toLocaleDateString();
        }
    }
}
</script>
