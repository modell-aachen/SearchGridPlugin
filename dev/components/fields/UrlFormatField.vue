<template>
    <td>
        <a v-bind:href="formatLink(params[1], doc)" v-bind:title="params[0]">
            <div v-if="!params[2]">{{params[0]}}</div>
            <img v-if="params[2]" :src="params[2]" />
        </a>
    </td>
</template>

<script>
export default {
    props: ['doc','params'],
    methods: {
      formatLink : function(linkText, doc){
        return linkText.replace(/\$([a-z-_]+)/g, function(a,b) {
                                                    return doc[b];
                                                 });
      }
    }
}
</script>
