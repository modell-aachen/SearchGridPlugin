import Helpers from './helpers.js'
import $ from 'jquery'
import FullTextFilter from "../dev/components/filters/FullTextFilter.vue"
import SelectFilter from "../dev/components/filters/SelectFilter.vue"

import MockupFacetValues from "./mockup_data/facet_values.json"

import './mockup_functions/foswiki.js'

describe("The full-text-filter", () => {
	let fullTextFilter = null;
	beforeEach(() => {
		$('body').empty();
		$('body').append("<div id='filterContainer'></div>");
		fullTextFilter = Helpers.createVueComponent(FullTextFilter, {
			el: '#filterContainer',
			propsData: {
				params: ["TitleText", "title", "language"]
			}
		});
	});
	xit('should return the correct filter query', () => {
		fullTextFilter.filterText = "";
		expect(fullTextFilter.filterQuery).toBe(null);
		fullTextFilter.filterText = "test";
		let expectedQuery = "({!tag=title q.op=OR}title:*test* OR {!tag=language q.op=OR}language:*test*)";
		expect(fullTextFilter.filterQuery).toBe(expectedQuery);
	});
	xit('should have the correct ID', () => {
		expect(fullTextFilter.id).toBe("TitleText_filter");
	});
	xit('should be flagged as default if no filter text is set', () => {
		fullTextFilter.filterText = "";
		expect(fullTextFilter.isDefault).toBe(true);
	});
	xit('should not be flagged as default if filter text is not empty', () => {
		fullTextFilter.filterText = "Some text";
		expect(fullTextFilter.isDefault).toBe(false);
	});
	xit('should have a dummy empty totalCount value', () => {
		expect(fullTextFilter.totalCount).toBe("");
	});
	xit('should reset the filter text when receiving a clear-filters message', () => {
		fullTextFilter.filterText = "Some text";
		fullTextFilter.$emit('clear-filters');
		expect(fullTextFilter.filterText).toBe("");
	});
});

describe("The select-filter", () => {
	let selectFilter = null;
	beforeEach(() => {
		selectFilter = Helpers.createVueComponent(SelectFilter, {
			el : () => {return 'body'},
			replace: false,
			propsData: {
				facetValues: MockupFacetValues,
				params: ["TitleText", "language"]
			}
		});
	});

	xit("should have the correct ID", () => {
		expect(selectFilter.id).toBe("TitleText_filter");
	});

	xit('should have a dummy empty totalCount value', () => {
		expect(selectFilter.totalCount).toBe("");
	});

	xit('should be flagged as default if selected option is the empty string', () => {
		selectFilter.selectedOption = '';
		expect(selectFilter.isDefault).toBe(true);
	});

	xit('should not be flagged as default if selected option is not empty', () => {
	  selectFilter.selectedOption = 'en';
	  expect(selectFilter.isDefault).toBe(false);
	});

	xit('should reset the selected option when receiving a clear-filters message', () => {
	  selectFilter.selectedOption = 'en';
	  selectFilter.$emit('clear-filters');
	  expect(selectFilter.selectedOption).toBe('');
	});

	xit('should update the selected facet value when the selected option is changed', (done) => {
	  selectFilter.selectedOption = 'de';
	  selectFilter.$nextTick(() => {
	  	expect(selectFilter.selectedFacet[0].field).toBe('de');
	  	selectFilter.selectedOption = "en";
	  	selectFilter.$nextTick(() => {
	  		expect(selectFilter.selectedFacet[0].field).toBe("en");
	  		selectFilter.selectedOption = "";
	  		selectFilter.$nextTick(() => {
		  		expect(selectFilter.selectedFacet.length).toBe(0);
		  		done();
		  	});
	  	});
	  });
	});
});