import Helpers from './helpers.js'
import $ from 'jquery'
import 'jasmine-ajax'
import ResponseMockup from './mockup_data/response.json'

import './mockup_functions/foswiki.js'

describe("The grid component", () => {
  let [grid, mockupGridPrefs] = [];

  beforeEach(() => {
    jasmine.Ajax.install();
    [grid, mockupGridPrefs] = Helpers.setupGrid();
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