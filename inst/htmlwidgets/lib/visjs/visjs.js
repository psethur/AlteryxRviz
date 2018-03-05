function drawNetwork(el, nodes, edges, options, isTree){
    var allNodes, network;
    var highlightActive = false;
    var nodesDataset;
    var edgesDataset;
    var nodeClicked = false;

    var opts = nodes.map(function(d){
      //d.id = d.name
      //d.label = d.name
      return {text: d.name || "Label " + d.id, value: d.id}
    })

    if (options.miscopts){
      var miscopts = options.miscopts;
      delete options.miscopts;
    }

    nodesDataset = new vis.DataSet(nodes);
    edgesDataset = new vis.DataSet(edges);

    function addSearch(id, options){
      var $select = $(id).selectize({
         create: true,
         options: opts,
         placeholder: "Select nodes to view"
      })
      var selectize = $select[0].selectize
      selectize.on("change", function(x){
        if (x != ""){
          network.selectNodes(x.split(","))
          //network.focus(x)
          highlight(network.getSelection())
        }
      })
    }


    function redrawAll(){
      var data = {nodes: nodesDataset, edges: edgesDataset}
      var container = el
      network = new vis.Network(
        container, data, options
      )
      allNodes = nodesDataset.get({returnType:"Object"});
      for (var nodeId in allNodes){
        allNodes[nodeId]._color = allNodes[nodeId].color
      }
      network.on("click", function(params){
        var nodeId = params.nodes[0]
        nodeClicked = nodeId
        highlight(params)
        if (nodeId){
          drawTooltip(data.nodes.get(nodeId), miscopts.tooltipParams)
        } else {
          d3.select("#tooltip").style('visibility', 'hidden')
        }
      });
      if (true){
        network.on("hoverNode", function(params){
          console.log(params)
          var nodeId = params.node
          highlight(params)
          if (nodeId){
            drawTooltip(data.nodes.get(nodeId), miscopts.tooltipParams)
          } else {
            d3.select("#tooltip").style('visibility', 'hidden')
          }
        });
        network.on("blurNode", function(params){
          console.log(nodeClicked)
          if (!nodeClicked){
            d3.select("#tooltip").style("visibility", "hidden")
            //d3.select("#tooltip svg g").selectAll("*").remove()
            highlightDescendants({node: "xxxx"})
            //drawTooltip(data.nodes.get(0))
            //document.getElementById("tooltip").innerHTML = ""
          }
        })
      }
    }

    function highlight(params){
      if (isTree){
          highlightDescendants(params)
      } else{
          neighbourhoodHighlight(params)
      }
    }

    function drawTooltip(data, params){
      var tdiv = d3.select(el)
        .selectAll("#tooltip")
        .data([1])
      tdiv.enter().append("div")
        .attr("id", "tooltip")
        .attr("class", "vis-network-tooltip")
        .style("position", "absolute")
        .style("top", params.top || "110px")
        .style("left", params.left || "20px")
        .style("width", params.width || "210px")
        .style("height", params.height || "90px")
        .style('background', 'none')
        .style('border', 'none')
      //var prob = data.prob.split(",")
      //var prob_N = data.prob_N.split(",")
      var prob = data.probs
      var prob_N = data.counts
      //var labels = d3.range(prob.length).map(function(i){return "C" + i})
      var labels = miscopts.labels
      //var dat = d3.entries(data.prob)
      var dat = d3.range(prob.length).map(function(i){
        return {key: labels[i], value: +prob[i]}
      })
      //console.log(dat)
      //var col = d3.scale.category10()
      var col = miscopts.col
      d3.select("#tooltip")
        .style('visibility', 'visible')
      var svg = d3.select("#tooltip")
        .selectAll("g").data([dat])
      svg.enter()
         .append("svg")
         .append("g")
         .attr("transform", "translate(60, 10)")
      svg = d3.select("#tooltip").select("g")
      var offset = "translate(0, 10)"
      var title = svg.selectAll(".title").data([data])
      title.enter().append("text").attr("class", "title")
      title.attr({
        x: 0,
        y: 0
      }).text(function(d){
        return  d3.format("%.2f")(d.support) + "(" + d.n + ")"
      })
      var rect = svg.selectAll("rect").data(dat)
      rect.enter().append("rect").attr("transform", offset)
      rect
        .attr("x", function(d, i){return 0})
        .attr("y", function(d, i){return i*15})
        .attr("height", 15)
        .attr("width", function(d, i){return(d.value*100)})
        .attr("fill", function(d, i){return col[i]})
      var txt = svg.selectAll(".label").data(dat)
      txt.enter().append('text').classed('label', true)
        .attr("transform", offset)
      txt
        .attr("x", -60)
        .attr("y", function(d, i){return 7.5 +  i*15})
        .text(function(d, i){return d.key})
        .style('font-size', 10)
        .style("alignment-baseline", "middle")
      var txt = svg.selectAll(".value").data(dat)
      txt.enter().append('text').classed('value', true)
        .attr("transform", offset)
      txt
        .attr("x", function(d, i){return(d.value*100 + 5)})
        .attr("y", function(d, i){return 7.5 +  i*15})
        .text(function(d, i){
          return d3.format("%.2f")(d.value) + "(" + prob_N[i] + ")"
        })
        .style('font-size', 10)
        .style("alignment-baseline", "middle")
    }


    function neighbourhoodHighlight(params) {
        // if something is selected:
        if (params.nodes.length > 0) {
          highlightActive = true;
          var i,j;
          var selectedNode = params.nodes[0];
          var degrees = 2;

          // mark all nodes as hard to read.
          for (var nodeId in allNodes) {
            allNodes[nodeId].color = 'rgba(200,200,200,0.5)';
            if (allNodes[nodeId].hiddenLabel === undefined) {
              allNodes[nodeId].hiddenLabel = allNodes[nodeId].label;
              allNodes[nodeId].label = undefined;
            }
          }
          var connectedNodes = network.getConnectedNodes(selectedNode);
          var allConnectedNodes = [];

          // get the second degree nodes
          for (i = 1; i < degrees; i++) {
            for (j = 0; j < connectedNodes.length; j++) {
              allConnectedNodes = allConnectedNodes.concat(network.getConnectedNodes(connectedNodes[j]));
            }
          }

          // all second degree nodes get a different color and their label back
          for (i = 0; i < allConnectedNodes.length; i++) {
            allNodes[allConnectedNodes[i]].color = 'rgba(150,150,150,0.75)';
            if (allNodes[allConnectedNodes[i]].hiddenLabel !== undefined) {
              allNodes[allConnectedNodes[i]].label = allNodes[allConnectedNodes[i]].hiddenLabel;
              allNodes[allConnectedNodes[i]].hiddenLabel = undefined;
            }
          }

          // all first degree nodes get their own color and their label back
          for (i = 0; i < connectedNodes.length; i++) {
            allNodes[connectedNodes[i]].color = allNodes[connectedNodes[i]]._color
            /*
            if (allNodes[connectedNodes[i]].hiddenColor !== undefined){
              allNodes[connectedNodes[i]].color =  allNodes[connectedNodes[i]].hiddenColor
            } else {
              allNodes[connectedNodes[i]].color = undefined;
            }
            */


            if (allNodes[connectedNodes[i]].hiddenLabel !== undefined) {
              allNodes[connectedNodes[i]].label = allNodes[connectedNodes[i]].hiddenLabel;
              allNodes[connectedNodes[i]].hiddenLabel = undefined;
            }
          }

          // the main node gets its own color and its label back.
          allNodes[selectedNode].color = allNodes[selectedNode]._color
          if (allNodes[selectedNode].hiddenLabel !== undefined) {
            allNodes[selectedNode].label = allNodes[selectedNode].hiddenLabel;
            allNodes[selectedNode].hiddenLabel = undefined;
          }
        }
        else if (highlightActive === true) {
          // reset all nodes
          for (var nodeId in allNodes) {
            allNodes[nodeId].color = allNodes[nodeId]._color
            if (allNodes[nodeId].hiddenLabel !== undefined) {
              allNodes[nodeId].label = allNodes[nodeId].hiddenLabel;
              allNodes[nodeId].hiddenLabel = undefined;
            }
          }
          highlightActive = false
        }

        // transform the object into an array
        var updateArray = [];
        for (nodeId in allNodes) {
          if (allNodes.hasOwnProperty(nodeId)) {
            updateArray.push(allNodes[nodeId]);
          }
        }
        nodesDataset.update(updateArray);
     }
     function getParent(d){
       var x = network.getConnectedNodes(d)
       return x.filter(function(d_){return +d_ < +d})
     }

     function getAncestors(node){
         var ancestors = [node],
           next = [node],
           i = 0
         while (next.length){
           var p = getParent(next)
           p.forEach(function(pp){
             ancestors.push(pp)
           })
           next = p
           console.log(i)
           i = i + 1
         }
         console.log(ancestors)
         return(ancestors)
     }
     function getChildren(d){
      var x = network.getConnectedNodes(d)
      return x.filter(function(d_){return +d_ > +d})
     }
     function getDescendants(node){
        var tovisit = [],
            next = node,
            descendants = [],
            i = 0;
            while (next){
              descendants.push(next)
              c = getChildren(next)
              if (c.length > 0){
                c.forEach(function(cc){
                  tovisit.push(cc)
                })
              }
              next = tovisit.shift()
              i += 1
            }
         return(descendants)
     }

    function highlightDescendants(params){
      var nodeId = params.node || params.nodes[0]
      if (nodeId && nodeId != 'xxxx') {
          highlightActive = true
          //var desc = getDescendants(nodeId)
          var desc = getAncestors(nodeId)
          console.log(desc)
          for (var nodeId in allNodes) {
            allNodes[nodeId].color = 'rgba(200,200,200,0.5)';
          }
          desc.forEach(function(d){
            allNodes[d].color = allNodes[d]._color;
          })
      } else if (highlightActive === true) {
              // reset all nodes
              for (var nodeId in allNodes) {
                allNodes[nodeId].color = allNodes[nodeId]._color
                if (allNodes[nodeId].hiddenLabel !== undefined) {
                  allNodes[nodeId].label = allNodes[nodeId].hiddenLabel;
                  allNodes[nodeId].hiddenLabel = undefined;
                }
              }
              highlightActive = false
        }
      var updateArray = [];
      for (nodeId in allNodes) {
        if (allNodes.hasOwnProperty(nodeId)) {
           updateArray.push(allNodes[nodeId]);
        }
      }
      nodesDataset.update(updateArray);
    }

    /*
    $('button').on("click", function(){
      nodes.forEach(function(d){
        d._value = d.value
        d.value = 1
      })
      nodesDataset = new vis.DataSet(nodes);
      edgesDataset = new vis.DataSet(edges);
      var data = {nodes: nodesDataset, edges: edgesDataset}
      network.setData(data)
      network.redraw()
      allNodes = nodesDataset.get({returnType:"Object"});
      for (var nodeId in allNodes){
        allNodes[nodeId]._color = allNodes[nodeId].color
      }
      network.on("click", neighbourhoodHighlight);
    })
    */

    redrawAll()
    //$('body').attr("class", "application")
    addSearch("#search", opts)
    return network
}
