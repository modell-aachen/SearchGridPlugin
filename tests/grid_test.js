import Helpers from './helpers.js'
import $ from 'jquery'

import './mockup_functions/jsi18n.js'

describe("The grid component", () => {
  let [grid, mockupGridPrefs] = [];
  beforeAll(() => {
    [grid, mockupGridPrefs] = Helpers.setupGrid();
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
      for(var i = 0; i < gridRows.length; i++){
        expect($(gridRows[i]).find('td').length).toBe(mockupGridPrefs.fields.length);
      }
    });
  });
  describe("initializes filters and", () => {
    it("should render all defined filters", () => {
      let gridFilters = $(grid.$el).find('.search-grid-filters .search-grid-filter');
      expect(gridFilters.length).toBe(mockupGridPrefs.filters.length);
    });
  });
  describe("initializes facets and", () => {
    it("should render all defined facets", () => {
      let gridFacets = $(grid.$el).find('.search-grid-facets .facet');
      expect(gridFacets.length).toBe(mockupGridPrefs.facets.length);
    });
  });
});