HTMLWidgets.widget({

  name: 'iacf',

  type: 'output',

  initialize: function(el, width, height) {

    return {
      width: width,
      height: height
    }

  },

  renderValue: function(el, x, instance) {
     x.data = HTMLWidgets.dataframeToD3(x.data)
     //d3.select(el)
     // .datum(x)
     // .call(d3t.acfplot().height(instance.height))
     new acfChart("#" + el.id)
       .data(x)
       .options({xlab: x.xlab, ylab: x.ylab})
       .options({hline: x.hline})
       .options({line: {stroke: 'green', 'stroke-width': 3}})

  },

  resize: function(el, width, height, instance) {

  }

});
