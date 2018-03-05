HTMLWidgets.widget({

  name: 'c3',

  type: 'output',

  initialize: function(el, width, height) {

    return {
      // TODO: add instance fields as required
    }

  },

  renderValue: function(el, x, instance) {
    x.bindto = '#' + el.id
    x.data.json = HTMLWidgets.dataframeToD3(x.data.json)
    console.log(x)
    var chart = c3.generate(x)

  },

  resize: function(el, width, height, instance) {

  }

});
