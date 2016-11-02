import Helpers from './helpers.js'
import $ from 'jquery'

import './mockup_functions/jsi18n.js'

describe("The full-text-filter", () => {
  let [grid, mockupGridPrefs] = Helpers.setupGrid();
  let fullTextFilter = $(grid.$el).find(".full-text-filter");
  it('should return the correct filter query', () => {

  });
});