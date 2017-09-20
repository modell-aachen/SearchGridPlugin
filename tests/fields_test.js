import TestCase from 'FrontendUnitTestLibrary'
import moment from 'moment'
// import $ from 'jquery'

import AmpelField from '../dev/components/fields/AmpelField.vue'

describe("Test SearchGridFields", () => {
  let ampelFieldNow = null;
  let ampelFieldBefore1 = null;
  let ampelFieldAfter7 = null;
  let ampelFieldInvalid = null;

  beforeAll(() => {
    ampelFieldAfter7 = createAmpel((moment().add('7','d').format("YYYY-MM-DTHH:mm:ssZ")),['field_Time_dt']).$mount();
    ampelFieldBefore1 = createAmpel((moment().add('-1','d').format("YYYY-MM-DTHH:mm:ssZ")),['field_Time_dt']).$mount();
    ampelFieldNow = createAmpel((moment().format("YYYY-MM-DTHH:mm:ssZ")),['field_Time_dt']).$mount();
    ampelFieldInvalid = createAmpel("InvalidDate",['field_Time_dt']).$mount();
  });

  beforeEach(() => {
  });

  afterEach(() => {
  });

  describe('AmpelField', () => {
    it('Check default values', () => {
      expect(ampelFieldNow.showDate).toBe(false);
      expect(ampelFieldNow.ampel.dueDate).toBe(moment().format("D.MM.YYYY"));
      expect(ampelFieldBefore1.ampel.dueDate).toBe(moment().subtract('1','d').format("D.MM.YYYY"));
      expect(ampelFieldAfter7.ampel.dueDate).toBe(moment().add('7','d').format("D.MM.YYYY"));

      expect(ampelFieldNow.ampel.warnStatus).toBe('yellow');
      expect(ampelFieldAfter7.ampel.warnStatus).toBe('green');
      expect(ampelFieldBefore1.ampel.warnStatus).toBe('red');
    });

    it('Check status images', () => {
      expect(ampelFieldNow.ampel.statusImage).toBe('ampel_o.png');
      expect(ampelFieldAfter7.ampel.statusImage).toBe('ampel_g.png');
      expect(ampelFieldBefore1.ampel.statusImage).toBe('ampel_r.png');
    });

    it('Check days remaining', () => {
      expect(ampelFieldNow.ampel.daysRemaining).toBe(0);
      expect(ampelFieldAfter7.ampel.daysRemaining).toBe(7);
      expect(ampelFieldBefore1.ampel.daysRemaining).toBe(-1);
    });

    it('Check invalid date', () => {
      expect(ampelFieldInvalid.ampel.warnStatus).toBe("none");
      expect(ampelFieldInvalid.ampel.statusImage).toBe("ampel.png");
    });

    it('Check custom params', () => {
      let ampelField = createAmpel((moment().add('4','d').format("YYYY-MM-DTHH:mm:ssZ")),['field_Time_dt',1,6,3]).$mount();
      expect(ampelField.ampel.daysRemaining).toBe(4);
      expect(ampelField.ampel.warnStatus).toBe('yellow');
      expect(ampelField.ampel.statusImage).toBe('ampel_o.png');
    });
  });

  function createAmpel (date,params){
    return TestCase.createVueComponent(AmpelField, {
      propsData: {doc: {'field_Time_dt' : date}, params: params},
      store: TestCase.vuexStore
    });
  }
});
