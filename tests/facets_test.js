import Helpers from './helpers.js'
import $ from 'jquery'
import SingleSelectFacet from '../dev/components/facets/SingleSelectFacet.vue'
import MultiSelectFacet from '../dev/components/facets/MultiSelectFacet.vue'

import MockupFacetValues from "./mockup_data/facet_values.json"

import './mockup_functions/foswiki.js'

describe("The single-select-facet", () => {
  let singleSelectFacet = null;
  beforeEach(() => {
    $('body').empty();
    $('body').append("<div id='facetContainer'></div>");
    singleSelectFacet = Helpers.createVueComponent(SingleSelectFacet, {
      el: '#facetContainer',
      propsData: {
        params: ["TitleText", "language"],
        facetValues: MockupFacetValues,
        facetTotalCounts: 10
      }
    });
  });

  xit('should return null as the filter query if no facet is selected', () => {
    expect(singleSelectFacet.filterQuery).toBe(null);
  });

  xit('should return the correct filter query if a facet is selected', (done) => {
    singleSelectFacet.selectedRadio = "en";
    let expectedQuery = "{!tag=language q.op=OR}language:(en)";
    singleSelectFacet.$nextTick(() => {
      expect(singleSelectFacet.filterQuery).toBe(expectedQuery);
      done();
    });
  });
});

describe("The multi-select-facet", () => {
  let multiSelectFacet = null;
  beforeEach(() => {
    $('body').empty();
    $('body').append("<div id='facetContainer'></div>");
    multiSelectFacet = Helpers.createVueComponent(MultiSelectFacet, {
      el : () => {return 'body'},
      replace: false,
      propsData: {
        params: ["TitleText", "author"],
        facetValues: MockupFacetValues,
        facetTotalCounts: 10
      }
    });
  });

  xit('should return null as the filter query if no facet is selected', () => {
    expect(multiSelectFacet.filterQuery).toBe(null);
  });

  xit('should return the correct filter query if a single checkbox is checked', (done) => {
    multiSelectFacet.selectedCheckboxes = ["JohnDoe"];
    let expectedQuery = "{!tag=author q.op=OR}author:(JohnDoe)";
    multiSelectFacet.$nextTick(() => {
      expect(multiSelectFacet.filterQuery).toBe(expectedQuery);
      done();
    });
  });

  xit('should return the correct filter query if multiple checkboxes are checked', (done) => {
    multiSelectFacet.selectedCheckboxes = ["JohnDoe", "AdminUser"];
    let expectedQuery = "{!tag=author q.op=OR}author:(JohnDoe AdminUser)";
    multiSelectFacet.$nextTick(() => {
      expect(multiSelectFacet.filterQuery).toBe(expectedQuery);
      done();
    });
  });

  xit('should return correctly escaped filter queries if fields contain special characters', (done) => {
    multiSelectFacet.selectedCheckboxes = ["+ -:()||&&!", "AdminUser"];
    let expectedQuery = "{!tag=author q.op=OR}author:(\\+\\ \\-\\:\\(\\)\\||\\&&\\! AdminUser)";
    multiSelectFacet.$nextTick(() => {
      expect(multiSelectFacet.filterQuery).toBe(expectedQuery);
      done();
    });
  });
});