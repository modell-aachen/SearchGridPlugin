import Vue from 'vue/dist/vue.js'
import Grid from './Grid.vue'

$( function () {
new Vue({
    el: 'body',
    components: {
      grid: Grid
    }
})
})
