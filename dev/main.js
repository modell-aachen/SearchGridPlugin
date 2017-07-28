import SearchGridStoreModule from "./store/index.js";
import Grid from './components/Grid.vue'

Vue.registerStoreModule("searchGrid", SearchGridStoreModule);

let SearchGridPlugin = {
    registerField: function(name, component){
        Vue.component(name, component);
    },
    registerComponent: function(name, component){
        Vue.component(name, component);
    }
};
window.SearchGridPlugin = SearchGridPlugin;

Vue.onDocumentReady( function () {
    Vue.instantiateEach('.SearchGridContainer', {
        components: {
            grid: Grid
        },
        created: function () {
            this.$moment.locale(this.$lang);
        }
    });
})
