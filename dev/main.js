import Vue from 'vue/dist/vue.js'
import TopicGrid from './components/TopicGrid.vue'
import de from './locales/jsi18n.SearchGrid.de.js'

$( function () {
new Vue({
    el: '.foswikiTopic',
    data: {
        instances: 0
    },
    methods: {
        updateInstanceCounter: function(){
            this.instances++;
        }
    },
    components: {
      grid: TopicGrid
    }
})
})
