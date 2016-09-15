<template>
    <table class="tablesorter">
<thead>
<th v-for="field in prefs.fields">{{field.title}}</th>
</thead>
<tbody>
<tr v-for="result in results">
<template v-for="field in prefs.fields">
<component :is="field.component" params="{{field.params}}"></component>
</template>
</tr>
</tbody>
</table>
</template>

<script>
import TitleField from './fields/TitleField.vue'
import TextField from './fields/TextField.vue'
export default {
    data : function () {
       return {
          results: [],
          prefs: {}
       }
    },
    components : {
      "title-field" : TitleField,
      "text-field" : TextField
    },
    ready: function () {
      this.$set('prefs', JSON.parse($('.SEARCHGRIDPREF').html()));
      var self = this;

      var results = $.get( "/bin/rest/SolrPlugin/proxy", {"q":this.prefs.q},function(result){
          self.results = result.response.docs;
      });
    }
}
</script>
