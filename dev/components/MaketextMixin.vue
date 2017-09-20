<script>
export default {
  methods: {
    maketext : function(text, params) {
      if(params){
        let args = ['SearchGrid', text];
        return this.$foswiki.jsi18n.get.apply(null, args.concat(params));
      }else{
        return this.$foswiki.jsi18n.get('SearchGrid', text);
      }
    }
  }
}

</script>
