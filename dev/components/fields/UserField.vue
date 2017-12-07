<template>
    <td v-if="shouldRenderUserIcon">
        <template v-for="(userName, index) in userNames">
            {{userName}} <vue-user-card :id="userIds[index]" :key="index"></vue-user-card>
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
      shouldRenderUserIcon: function() {
        return this.isEmployeeEnabled && parseInt(this.$foswiki.getPreference('EMPLOYEESAPP_USERICON'));
      },
      userNames: function(){
        let userNames = this.doc[this.params[0]] || "";
        return userNames.split(", ");
      },
      userIds: function(){
        let userIds = this.doc[this.params[1]] || "";
        return userIds.split(", ");
      }
    }
}
</script>
