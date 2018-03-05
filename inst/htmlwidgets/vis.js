HTMLWidgets.widget({

  name: 'vis',

  type: 'output',

  initialize: function(el, width, height) {

    return {
      // TODO: add instance fields as required
    }

  },

  renderValue: function(el, x, instance) {
    // HACK: set all nodes to group 1 if not specified
    // this ensures that neighborHighlight works as expected
    if (x.options){
      var isTree
      if (x.options.tree) {
        isTree = true
      } else {
        isTree = false
      };
      delete x.options.tree;
    } else {
      isTree = false;
    }
    if (Object.keys(x.nodes).indexOf("group") < 0){
      x.nodes.group = x.nodes.id.map(function(d, i){
        return 1
      })
    }

    var nodes = HTMLWidgets.dataframeToD3(x.nodes)

    /* For trees, unpack probability and counts, if present */
    if (isTree){
      nodes.forEach(function(d){
        if (d.probs) {
          d.probs = d.probs.split(",").map(Number)
          d.counts = d.counts.split(",").map(Number)
        }
      })
    }


    nodes.forEach(function(d){
      if (Object.keys(d).indexOf('image') >= 0){
        if (d.image == null){
          delete d.image
        }
      }
    })
    //var nodes = new vis.DataSet(nodes1)
   // var edges = new vis.DataSet(HTMLWidgets.dataframeToD3(x.edges))
    if (Object.keys(x.edges).indexOf("weight") >= 0){
      x.edges.value = x.edges.weight
      delete x.edges.weight
    }
    var edges = HTMLWidgets.dataframeToD3(x.edges)
    var options = x.options || {}
    $(document).ready(function(){
      el.network = drawNetwork(el, nodes, edges, options, isTree)
    })
  },

  resize: function(el, width, height, instance) {
    if (el.network){
      el.network.fit()
    }
  }

});
