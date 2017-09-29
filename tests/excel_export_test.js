import TestCase from 'FrontendUnitTestLibrary'

import ExcelFieldRenderer from '../dev/components/excel_export/FieldRenderer.js'

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

  it('renders date-fields as locale date string', () => {
    const testDate = "2017-09-22T12:49:46Z";
    const solrDocument = {
      date: testDate
    };
    const field = {
      component: "date-field",
      params: ["date"]
    };

    spyOn(Date.prototype, "toLocaleDateString").and.callFake(function() {
      return this;
    });

    const date = ExcelFieldRenderer.renderFieldForDocument(solrDocument, field);

    expect(Date.prototype.toLocaleDateString).toHaveBeenCalled();
    expect(date).toEqual(jasmine.any(Date));
    expect(date.getTime()).toBe(1506084586000);
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
