<template>
    <td>
        <div class="solrSearchHit solrTopicHit clearfix">
            <h3 title="topic">
                <img class="solrHitIcon" v-bind:src="doc['icon']" height="16" width="16"></img>
                <a href="{{doc['url']}}">{{doc["title"]}}</a>
                <span class="foswikiGrayText foswikiSmallish solrContainerLink"> in <a href="{{doc['container_url']}}">{{doc["web"]}}</a>
                <em v-if="doc['workflow_controlled_b']" style="font-size: 0.9em;" title="not approved">({{doc['workflowmeta_name_s_dv']}})</em>
                <img class="modacFlag" src="/pub/System/FamFamFamFlagIcons/{{language}}.png" title="{{language}}"></span>
            </h3>
            <div class="solrHilite">{{doc["text"]}}</div>
            <div class="solrRevisoin">{{date}}, {{doc["author_s"]}}</div>
        </div>
    </td>
</template>

<script>
import Moment from 'moment'
import 'moment/locale/de'
import 'moment/locale/fr'
export default {
    props: ['doc','params','language'],
    computed: {
        language: function() {
            if (this.doc['language'] === 'en'){
                return 'gb';
            } else {
                return this.doc['language'];
            }
        },
        date: function(){
            return Moment(this.doc['date']).locale(this.language).format('LLLL');
        }
    }
}
</script>
