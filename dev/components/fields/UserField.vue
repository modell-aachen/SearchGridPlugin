<template>
  <td v-if="isEmployeeEnabled">
    <template v-for="(userName, index) in userNames">
      {{userName}} <vue-user-card :id="userIds[index]"></vue-user-card>
    </template>
  </td>
  <td v-else>{{doc[params[0]]}}</td>
</template>

<script>
export default {
    props: ['doc','params'],
    computed: {
      isEmployeeEnabled: function() {
        return 'vue-user-card' in Vue.options.components;
      },
      userNames: function(){
        return this.doc[this.params[0]].split(", ");
      },
      userIds: function(){
        return this.doc[this.params[1]].split(", ");
      }
    }
}
</script>
