<script>
/*global foswiki:true*/
export default {
    methods: {
        maketext : function(text) {
            return foswiki.jsi18n.get('SearchGrid', text);
        }
    }
}
</script>
