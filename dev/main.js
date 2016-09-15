import Vue from 'vue/dist/vue.js'
import TopicGrid from './components/TopicGrid.vue'

$( function () {
new Vue({
    el: '.foswikiTopic',
    components: {
      grid: TopicGrid
    }
})
})
