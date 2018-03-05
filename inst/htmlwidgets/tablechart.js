HTMLWidgets.widget({

  name: 'tablechart',

  type: 'output',

  initialize: function(el, width, height) {

    return {
      // TODO: add instance fields as required
    }

  },

  renderValue: function(el, x, instance) {
    d3.select(el).selectAll("div")
     .data(x.data).enter()
     .append("div")
     .call(tablechart())
  },

  resize: function(el, width, height, instance) {

  }

});
