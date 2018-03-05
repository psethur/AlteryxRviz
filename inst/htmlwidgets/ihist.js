HTMLWidgets.widget({

  name: 'ihist',

  type: 'output',

  initialize: function(el, width, height) {

    return {
      // TODO: add instance fields as required
    }

  },

  renderValue: function(el, x, instance) {

    var myhist = makeHistogram('#' + el.id, x.data)
    if (x.options){
      myhist.options(x.options)
    }

  },

  resize: function(el, width, height, instance) {

  }

});
