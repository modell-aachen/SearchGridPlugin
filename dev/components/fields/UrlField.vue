<template>
<td>
    <a href="{{parsedUrl}}">{{doc[params[0]]}}</a>
</td>
</template>

<script>
export default {
    props: ['doc','params'],
	computed: {
		//Used to parse an solrField, which is not an URL to an URL
		parsedUrl: function() {
			var url = this.doc[this.params[1]];
			if(url.substring(0,1) == "/") {
				return url;
			} else {
				return "/".concat(url);
			}
		}
	}
}
</script>
