<template>
  <div v-if="shouldRenderUserIcon">
    <template v-for="user in users">
      {{user.name}}
      <vue-user-card
        v-if="!user.name.includes('Group')"
        :id="user.id">
      </vue-user-card><br>
    </template>
  </div>
  <div v-else>
    <template v-for="user in users">
      {{user.name}}<br>
    </template>
  </div>
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
      },
      users: function() {
        let users = this.userNames.map((name, index) => {
          return {
            name,
            id: this.userIds[index]
          };
        });
        return users.sort((a,b) => {
              let lcNameA = a.name.toLowerCase();
              let lcNameB = b.name.toLowerCase();
              return lcNameA.localeCompare(lcNameB);
        });
      }
    }
}
</script>
