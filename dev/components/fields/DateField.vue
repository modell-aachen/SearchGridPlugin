<template>
<td>{{date}}</td>
</template>

<script>
import Moment from 'moment'
export default {
    props: ['params'],
    computed: {
    	date: function(){
    		return Moment(this.params[0]);
    		//return this.params[0];
    	}
    }
}
</script>
