import Vue from 'vue'
import Grid from '../dev/components/Grid.vue'
import GridPrefs from './mockup_data/all_feature_grid_prefs.json'
import $ from 'jquery'

let createGrid = (instance) => {
  const Ctor = Vue.extend(Grid);
  let grid = new Ctor({
    el : () => {return 'body'},
    propsData: {instances: instance},
    replace: false
  });
  return grid;
};

let createPref = (instance, prefJSON) => {
  let stringifiedJSON = JSON.stringify(prefJSON);
  $(`<script class='SEARCHGRIDPREF${instance}' type='text/json'>${stringifiedJSON}</script>`).appendTo('html');
};

export default {
	setupGrid() {
		createPref(0, GridPrefs);
		return [createGrid(0), GridPrefs];
	}
}