import Vue from 'vue'
import Grid from '../dev/components/Grid.vue'
import DummyResponse from './dummy_response.json'
import DummyPrefs from './dummy_prefs.json'
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

window.foswiki = {
  jsi18n: {
    get(){
      return "MAKETEXT";
    }
  }
};

let createPref = (instance, prefJSON) => {
  let stringifiedJSON = JSON.stringify(prefJSON);
  $(`<script class='SEARCHGRIDPREF${instance}' type='text/json'>${stringifiedJSON}</script>`).appendTo('html');
};

describe("The grid component", () => {
  createPref(0, DummyPrefs);
  let grid = createGrid(0);

  describe("loads preferences on init and", () => {
    it("should set the preferences correctly", () => {
      expect(grid.prefs).toEqual(DummyPrefs);
    });
    it("should set the number of results per page correctly", () => {
      expect(grid.resultsPerPage).toBe(DummyPrefs.resultsPerPage);
    });
    it("should set the number of results correctly", () => {
      expect(grid.numResults).toBe(DummyPrefs.result.response.numFound);
    });
    it("should set the initial result set correctly", () => {
      expect(grid.results).toEqual(DummyPrefs.result.response.docs);
    });
    it("should set the initial sorting correctly", () => {
      expect(grid.sortField).toBe(DummyPrefs.initialSort.field);
      expect(grid.sort).toBe(DummyPrefs.initialSort.sort);
    });
    it("should render the initial result set correctly", () => {
      let gridRows = $(grid.$el).find('.searchGridResults tbody').find('tr');
      expect(gridRows.length).toBe(DummyPrefs.result.response.docs.length);
      for(var i = 0; i < gridRows.length; i++){
        expect($(gridRows[i]).find('td').length).toBe(DummyPrefs.fields.length);
      }
    });
  });
  describe("initializes filters and", () => {
    it("should render all defined filters", () => {
      let gridFilters = $(grid.$el).find('.search-grid-filters .search-grid-filter');
      expect(gridFilters.length).toBe(DummyPrefs.filters.length);
    });
  });
});