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
    $('.SearchGridContainer').each(function(i,element){
        new Vue({
            el: element,
            store: VueJSPlugin.rootStore,
            components: {
                grid: Grid
            },
            created: function () {
                moment.locale($("html").attr("lang"));
            }
        })
    });
})
