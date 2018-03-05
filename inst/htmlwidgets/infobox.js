HTMLWidgets.widget({

  name: 'infobox',

  type: 'output',

  initialize: function(el, width, height) {

    return {
      // TODO: add instance fields as required
    }

  },

  renderValue: function(el, x, instance) {
    //dummyData.div = x.div
    renderInfoBox(el, x)
  },

  resize: function(el, width, height, instance) {

  }

});
