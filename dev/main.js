import Vue from 'vue/dist/vue.js'
import Grid from './components/TopicGrid.vue'

$( function () {
new Vue({
    el: 'body',
    components: {
      grid: Grid
    }
})
})
