<template>
  <td v-if="shouldRenderUserIcon">
    <template v-for="userName in sortedUserNames">
      {{userHash[userName].displayName}}
      <vue-user-card
        v-if="!userHash[userName].displayName.includes('Group')"
        :id="userHash[userName].cuid">
      </vue-user-card><br>
    </template>
  </td>
  <td v-else>
    <template v-for="userName in sortedUserNames">
      {{userHash[userName].displayName}}<br>
    </template>
  </td>
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
      sortedUserNames: function() {
        let lowerCaseNames = this.userNames.map((userName) => {
          return userName.toLowerCase();
        });
        return lowerCaseNames.sort();
      },
      userHash: function() {
        let users = {};
        for(let i=0; i < this.userNames.length; i++) {
          users[this.userNames[i].toLowerCase()] = {
            cuid: this.userIds[i],
            displayName: this.userNames[i]
          }
        }
        return users;
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
