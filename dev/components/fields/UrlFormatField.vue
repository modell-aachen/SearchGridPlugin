<template>
<td>
    <a href="{{formatLink(params[1])}}" title="{{params[0]}}">
        <div v-if="!params[2]">{{params[0]}}</div>
        <img v-if="params[2]" :src="params[2]" />
    </a>
</td>
</template>

<script>
export default {
    props: ['doc','params'],
    methods: {
      formatLink : function(linkText){
        var self = this;
        return linkText.replace(/\$([a-z-_]+)/g, function(a,b) {
                                                    return self.doc[b];
                                                 });
      }
    }
}
</script>
