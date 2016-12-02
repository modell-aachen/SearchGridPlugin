<script>
/*global foswiki*/
export default {
    methods: {
        maketext : function(text) {
            return foswiki.jsi18n.get('SearchGrid', text);
        }
    }
}
</script>
