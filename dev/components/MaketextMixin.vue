<script>
export default {
    methods: {
        maketext : function(text) {
            return this.$foswiki.jsi18n.get('SearchGrid', text);
        }
    }
}
</script>
