import 'es6-promise/auto'
import $ from 'jquery';
import Vue from 'vue';
import Vuex from 'vuex';
import Grid from '../dev/components/Grid.vue'
import GridPrefs from './mockup_data/all_feature_grid_prefs.json'
import SearchGridStoreModule from "../dev/store/index.js";


Vue.use(Vuex);
Vue.config.productionTip = false;

let MockupStore = new Vuex.Store({});
MockupStore.registerModule("searchGrid", SearchGridStoreModule);

let createGrid = (instance) => {
  const Ctor = Vue.extend(Grid);
  let grid = new Ctor({
    propsData: {preferencesSelector: `SEARCHGRIDPREF_${instance}`},
    store: MockupStore
  });
  grid.$mount();
  return grid;
};

let createPref = (instance, prefJSON) => {
  let stringifiedJSON = JSON.stringify(prefJSON);
  $(`<script class='SEARCHGRIDPREF_${instance}' type='text/json'>${stringifiedJSON}</script>`).appendTo('html');
};

export default {
	setupGrid() {
		createPref(0, GridPrefs);
		return [createGrid(0), GridPrefs];
	},
  createVueComponent(componentDefinition, constructionOptions) {
    const Ctor = Vue.extend(componentDefinition);
    return new Ctor(constructionOptions);
  }
}