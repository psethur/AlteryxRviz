HTMLWidgets.widget({

  name: 'iConfusionMatrix',

  type: 'output',

  initialize: function(el, width, height) {

    return {
      // TODO: add instance fields as required
    }

  },

  renderValue: function(el, x, instance) {
    x.data = HTMLWidgets.dataframeToD3(x.data)
    renderHeatMap(el, x)

  },

  resize: function(el, width, height, instance) {

  }

});
