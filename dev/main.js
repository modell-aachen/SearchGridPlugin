/* global Vue moment window $ VueJSPlugin */

import "./store/index.js";
import Grid from './components/Grid.vue'

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
        store: VueJSPlugin.rootStore,
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
        },
        created: function () {
            moment.locale($("html").attr("lang"));
        }
    })
})
