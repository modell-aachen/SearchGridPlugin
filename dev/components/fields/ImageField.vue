<template>
<td>
	<a href="{{url}}" v-bind:class="classObject">
	<img :src="this.doc[params[0]]">
	</a>
</td>
</template>

<script>
export default {
    props: ['doc','params'],
    data: function() {
    	let dataObject = {
	    	classObject: {
	    		"inactive-link": true
	    	}
	    }
	    if(this.params.length >= 3 && this.params[2] !== "")
    		dataObject.classObject[this.params[2]] = true;

    	return dataObject
    },
    computed: {
    	url(){
    		if(this.params.length < 2)
    			return "";
    		return this.doc[this.params[1]];
    	}
    },
    ready: function(){
    	if(this.url !== "")
    		this.classObject["inactive-link"] = false;
    }
}
</script>

<style lang="sass">
.inactive-link {
	pointer-events: none;
	cursor: default;
}

</style>