import TestCase from 'FrontendUnitTestLibrary'
import $ from 'jquery'
import 'jasmine-ajax'
import SearchGridStoreModule from "../dev/store/index.js";
import Grid from '../dev/components/Grid.vue'
import GridPrefs from './mockup_data/all_feature_grid_prefs.json'
import ResponseMockup from './mockup_data/response.json'
import Base64 from 'js-base64'

import './mockup_functions/foswiki.js'

Vue.registerStoreModule("searchGrid", SearchGridStoreModule);
describe("The grid component", () => {
  let [grid, mockupGridPrefs] = [];

  let setupGrid = function() {
    let stringifiedJSON = JSON.stringify(GridPrefs);
    stringifiedJSON = Base64.Base64.encode(stringifiedJSON);
    $(`<script class='SEARCHGRIDPREF_0' type='text/json'>${stringifiedJSON}</script>`).appendTo('html');
    let grid = TestCase.createVueComponent(Grid, {
      propsData: {preferencesSelector: `SEARCHGRIDPREF_0`},
      store: TestCase.vuexStore
    });
    grid.$mount();
    return [grid, GridPrefs];
  };

  beforeEach(() => {
    jasmine.Ajax.install();
    [grid, mockupGridPrefs] = setupGrid();
  });

  afterEach(() => {
    jasmine.Ajax.uninstall();
  });

  describe("loads preferences on init and", () => {
    it("should set the preferences correctly", () => {
      expect(grid.prefs).toEqual(mockupGridPrefs);
    });
    it("should set the number of results per page correctly", () => {
      expect(grid.resultsPerPage).toBe(mockupGridPrefs.resultsPerPage);
    });
    it("should set the number of results correctly", () => {
      expect(grid.numResults).toBe(mockupGridPrefs.result.response.numFound);
    });
    it("should set the initial result set correctly", () => {
      expect(grid.results).toEqual(mockupGridPrefs.result.response.docs);
    });
    it("should set the initial sorting correctly", () => {
      expect(grid.sortField).toBe(mockupGridPrefs.initialSort.field);
      expect(grid.sort).toBe(mockupGridPrefs.initialSort.sort);
    });
    it("should render the initial result set correctly", () => {
      let gridRows = $(grid.$el).find('.search-grid-results tbody').find('tr');
      expect(gridRows.length).toBe(mockupGridPrefs.result.response.docs.length);
      for(let i = 0; i < gridRows.length; i++){
        expect($(gridRows[i]).find('td').length).toBe(mockupGridPrefs.fields.length);
      }
    });
  });
  describe("initializes filters and", () => {
    it("should render all defined filters", () => {
      let gridFilters = $(grid.$el).find('.search-grid-top-bar .search-grid-filter');
      expect(gridFilters.length).toBe(mockupGridPrefs.filters.length);
    });
  });
  describe("initializes facets and", () => {
    it("should render all defined facets", () => {
      let gridFacets = $(grid.$el).find('.search-grid-facets .facet');
      expect(gridFacets.length).toBe(mockupGridPrefs.facets.length);
    });
  });

  it('should be in a loading state when fetching data', () => {
    expect(grid.isLoading).toBe(false);
    grid.fetchData();
    expect(grid.isLoading).toBe(true);
    jasmine.Ajax.requests.mostRecent().respondWith({
      "status": 200,
      "contentType": 'text/plain',
      "responseText": JSON.stringify(ResponseMockup)
    });
    expect(grid.isLoading).toBe(false);
  });

  it('should set an error message when fetching data fails', () => {
    grid.fetchData();
    expect(grid.requestFailed).toBe(false);
    jasmine.Ajax.requests.mostRecent().respondWith({
      "status": 500,
      "contentType": 'text/plain',
      "responseText": "Server error",
      "statusText": "Server error"
    });
    expect(grid.requestFailed).toBe(true);
    expect(grid.errorMessage).toBe("Server error");
  });
});
