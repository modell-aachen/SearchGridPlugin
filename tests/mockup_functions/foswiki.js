window.foswiki = {
    preferences: {
        SCRIPTURL: "rest"
    },
  jsi18n: {
    get(module, text){
      return "MT:" + text;
    }
  },
  getScriptUrl: function() {
    return "SCRIPTURL";
  }
};