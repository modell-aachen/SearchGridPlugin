<template>
<td><a href="{{doc[params[1]]}}">{{doc[params[0]]}}</a></td>
</template>

<script>
export default {
    props: ['doc','params'],
}
</script>
