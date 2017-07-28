<template>
    <td>
        <template v-for="item in getList()">{{item}}<br v-if="showMoreHint"></template>
        <template v-if="more">{{gettext('and')}} <span class="more-hint">{{gettext('[_1] more', more)}}</span></template>
    </td>
</template>

<script>
export default {
    props: ['doc','params'],
    computed: {
        field() {
            return this.params[0];
        },
        limit() {
            return this.params[3];
        },
        more() {
            if (this.doc[this.field] && /^\d+$/.test(this.limit)) {
                let limit = parseInt(this.limit);
                let length = this.doc[this.field].length;

                if (length > limit) {
                    return length - limit;
                }
            }

            return undefined;
        },
        separateBySpace() {
            return this.params[1];
        },
        separator() {
            return this.params[2];
        },
        showMoreHint() {
            return !this.more;
        }
    },
    methods: {
        getList: function() {
            if (!this.doc[this.field]) return "";

            let data = this.doc[this.field];
            if (/^\d+$/.test(this.limit)) {
                data = data.slice(0, parseInt(this.limit));
            }

            if (this.separator !== undefined) {
                return [data.join(this.separator + (this.separateBySpace ? ' ' : ''))];
            }

            if(this.separateBySpace){
                return [data.join(" ")];
            }
            else{
                return data;
            }
        },
        gettext: function(text, param) {
            return window.jsi18n.get('SearchGrid', text, param);
        }
    }
}
</script>

<style>
span.more-hint {
    color: #6cd2e8;
}
</style>
