<template>
<td>
    <template v-for="(item, index) in splitList()"> 
    <a v-bind:href=item.Url>
        {{item.Title}}<br>
    </a>
    </template>
</td>
</template>

<script>
export default {
    props: ['doc','params'],
    computed: {
        field(){
            return this.params[0];
        },
        seperateBySpace(){
            return this.params[1];
		}
    },
    methods: {
        splitList: function(){
            let url = this.doc[this.seperateBySpace];
			if(!url){
				return "";
			}

			url = url.split(", ");
			
			url.forEach(function(element, index){
				if(!element.startsWith("/")){
					url[index] = "/"+element;
					
				}
			});
             
            let topicTitle = this.doc[this.field];
            topicTitle = topicTitle.split(",");
            
            var result = new Array();
            
            for(var i = 0 ; i < url.length ; i++){
                result[i] = {Url:url[i],Title:topicTitle[i]};
            }
            
            return result;
			
        }
    }
}
</script>
