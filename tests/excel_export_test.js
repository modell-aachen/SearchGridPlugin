import TestCase from 'FrontendUnitTestLibrary'

import ExcelFieldRenderer from '../dev/components/excel_export/FieldRenderer.js'
import UrlFormatField from '../dev/components/fields/UrlFormatField.vue';

describe("The FieldRenderer", () => {

  beforeAll(() => {
  });

  beforeEach(() => {
  });

  afterEach(() => {
  });

  it('supports the rendering of text-fields', () => {
    expect(ExcelFieldRenderer.supportsFieldRendering("text-field")).toBe(true);
  });

  it('supports the rendering of date-fields', () => {
    expect(ExcelFieldRenderer.supportsFieldRendering("date-field")).toBe(true);
  });

  it('supports the rendering of list-fields', () => {
    expect(ExcelFieldRenderer.supportsFieldRendering("list-field")).toBe(true);
  });

  it('supports the rendering of url-fields', () => {
    expect(ExcelFieldRenderer.supportsFieldRendering("url-field")).toBe(true);
  });

  it('supports the rendering of url-format-fields', () => {
    expect(ExcelFieldRenderer.supportsFieldRendering("url-format-field")).toBe(true);
  });

  it('renders text-fields as pure text', () => {
    const testTitle = "Test title";
    const solrDocument = {
      title: testTitle
    };
    const field = {
      component: "text-field",
      params: ["title"]
    };

    expect(ExcelFieldRenderer.renderFieldForDocument(solrDocument, field)).toBe(testTitle);
  });

  it('renders url-fields as TEXT (URL)', () => {
    const testTitle = "Test title";
    const testUrl = "testUrl";
    const solrDocument = {
      title: testTitle,
      url: testUrl
    };
    const field = {
      component: "url-field",
      params: ["title", "url"]
    };

    spyOn(Vue.foswiki, "getScriptUrl").and.returnValue("http://wiki.de/view/");

    const expectedValue = `${testTitle} (http://wiki.de/view/${testUrl})`;
    expect(ExcelFieldRenderer.renderFieldForDocument(solrDocument, field)).toBe(expectedValue);
  });

  it('renders url-format-fields as TEXT (URL)', () => {
    const testUrlText = "Text";
    const testUrlFormat = "testUrl";
    const solrDocument = {};
    const field = {
      component: "url-format-field",
      params: [testUrlText, testUrlFormat]
    };

    spyOn(Vue.foswiki, "getScriptUrl").and.returnValue("http://wiki.de/view/");
    spyOn(UrlFormatField.methods, 'formatLink').and.returnValue("formatedLink");

    const expectedValue = `${testUrlText} (http://wiki.de/view/formatedLink)`;
    expect(ExcelFieldRenderer.renderFieldForDocument(solrDocument, field)).toBe(expectedValue);
    expect(UrlFormatField.methods.formatLink).toHaveBeenCalledWith(testUrlFormat, solrDocument);
  });

  it('renders date-fields as locale date string', () => {
    const testDate = "2017-09-22T12:49:46Z";
    const testDateEpoch = 1506084586000;
    const solrDocument = {
      date: testDate
    };
    const field = {
      component: "date-field",
      params: ["date"]
    };


    spyOn(Date.prototype, "toLocaleDateString").and.callFake(function() {
      /*
        Why this spy?
        To keep unit tests independent from the language of the browser
        in which they are executed we
        have to mock toLocaleDateString. The best locale independent thing
        we can return is the epoch time.
      */
      return this.getTime();
    });

    const date = ExcelFieldRenderer.renderFieldForDocument(solrDocument, field);

    expect(Date.prototype.toLocaleDateString).toHaveBeenCalled();
    expect(date).toBe(testDateEpoch);
  });

  it('renders list-fields as a comma separated string', () => {
    const testList = ["Rick","Morty","Beth","Mr. Meeseeks"];
    const solrDocument = {
      list: testList
    };
    const field = {
      component: "list-field",
      params: ["list"]
    };

    expect(ExcelFieldRenderer.renderFieldForDocument(solrDocument, field)).toBe("Rick,Morty,Beth,Mr. Meeseeks");
  });
});
