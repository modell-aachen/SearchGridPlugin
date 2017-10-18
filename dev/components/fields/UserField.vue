<template>
  <td v-if="isEmployeeEnabled">
    {{doc[params[0]]}} <vue-user-card :id="doc[params[1]]"></vue-user-card>
  </td>
  <td v-else>{{doc[params[0]]}}</td>
</template>

<script>
export default {
    props: ['doc','params'],
    computed: {
      isEmployeeEnabled: function() {
        return 'vue-user-card' in Vue.options.components;
      }
    }
}
</script>
