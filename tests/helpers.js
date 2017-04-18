import 'es6-promise/auto'

import './mockup_functions/vuejsplugin'
import Vue from 'vue';
import Grid from '../dev/components/Grid.vue'
import GridPrefs from './mockup_data/all_feature_grid_prefs.json'
import '../dev/store/index.js';

let createGrid = (instance) => {
  const Ctor = Vue.extend(Grid);
  let grid = new Ctor({
    el: '#gridContainer',
    propsData: {preferencesSelector: `SEARCHGRIDPREF_${instance}`},
    store: VueJSPlugin.rootStore
  });
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