import Vue from 'vue/dist/vue.js'
import TopicGrid from './components/TopicGrid.vue'

window.Vue = Vue;
window.registerCustomComponent = function(name, component){
    Vue.component(name, component);
};

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
