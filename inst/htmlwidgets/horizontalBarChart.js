HTMLWidgets.widget({

  name: 'horizontalBarChart',

  type: 'output',

  initialize: function(el, width, height) {

    return {
      // TODO: add instance fields as required
    }

  },

  renderValue: function(el, x, instance) {
    x.data.value = HTMLWidgets.dataframeToD3(x.data.value)
    renderHorizontalBarChart(el, x);
  },

  resize: function(el, width, height, instance) {

  }

});
