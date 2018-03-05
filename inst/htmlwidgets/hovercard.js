HTMLWidgets.widget({

  name: 'hovercard',

  type: 'output',

  initialize: function(el, width, height) {

    return {
      // TODO: add instance fields as required
    }

  },

  renderValue: function(el, x, instance) {
    el.innerText = x.text
    el.style.width = null
    el.style.height = null
    $(el).hovercard(
      {detailsHTML: x.details}
    )

  },

  resize: function(el, width, height, instance) {

  }

});
