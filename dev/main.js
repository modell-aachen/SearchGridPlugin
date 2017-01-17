import Vue from 'vue'
import Grid from './components/Grid.vue'

window.Vue = Vue;
var SearchGridPlugin = {
    registerField: function(name, component){
        Vue.component(name, component);
    },
    registerComponent: function(name, component){
        Vue.component(name, component);
    }
};
window.SearchGridPlugin = SearchGridPlugin;

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
            grid: Grid
        }
    })
})