<template>
    <div>
        <div class="solrSearchHit solrTopicHit clearfix">
            <h3 title="topic">
                <img class="solrHitIcon" :src="doc['icon']" height="16" width="16"></img>
                <a v-bind:href="doc['url']">{{doc["title"]}}</a>
                <span class="foswikiGrayText foswikiSmallish solrContainerLink"> {{sIn}} <a v-bind:href="doc['container_url']">{{doc["web"]}}</a>
                <em v-if="doc['workflow_controlled_b']" style="font-size: 0.9em;" title="not approved">({{doc['workflowmeta_name_s_dv']}})</em>
                <img class="modacFlag" :src="'/pub/System/FamFamFamFlagIcons/' + fieldLanguage + '.png'" v-bind:title="fieldLanguage"></span>
            </h3>
            <div class="solrHilite">{{doc["text"]}}</div>
            <div class="solrRevisoin">{{date}}, {{doc["author_s"]}}</div>
        </div>
    </div>
</template>

<script>
export default {
    props: ['doc','params','language'],
    data: function () {
        return {
            sIn: this.$foswiki.jsi18n.get('SearchGrid', 'in')
        }
    },
    computed: {
        fieldLanguage: function() {
            if (this.doc['language'] === 'en'){
                return 'gb';
            } else {
                return this.doc['language'];
            }
        },
        date: function(){
            return this.$moment(this.doc['date']);
        }
    }
}
</script>
