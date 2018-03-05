(function() {
  var heatMapConstructor, root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  heatMapConstructor = function(skeleton) {
    var A, S, layers, visualize;
    layers = skeleton.getLayerOrganizer();
    S = {
      x: d3.scale.ordinal(),
      y: d3.scale.ordinal(),
      c: d3.scale.linear()
    };
    A = {
      x: function(d) {
        return d.x;
      },
      y: function(d) {
        return d.y;
      },
      c: function(d) {
        return d.c;
      }
    };
    layers.create(['cells', 'y-axis', 'x-axis', 'accuracy']);
    visualize = function() {
      var H_, W_, accEnter, accuracy, cells, data, labels, opts, rectlabel, tooltipFn, tooltipFn2, txtheader, x, xAxis, xylabels, yAxis;
      data = skeleton.data();
      opts = skeleton.options();
      x = Math.min(skeleton.getInnerWidth(), skeleton.getInnerHeight());
      W_ = x;
      H_ = x;
      S.x.rangeRoundBands([0, W_]).domain(data.map(A.x));
      S.y.rangeRoundBands([0, H_]).domain(data.map(A.y));
      S.c.range(['white', 'rgb(0, 158, 115)']).domain([0, 1]);
      S.c2 = S.c.copy().range(['white', 'rgb(213, 94, 0)']);
      cells = layers.get('cells').selectAll('.cell').data(data);
      cells.enter().append('rect.cell');
      cells.attr({
        x: function(d) {
          return S.x(A.x(d));
        },
        y: function(d) {
          return S.y(A.y(d));
        },
        width: S.x.rangeBand(),
        height: S.y.rangeBand(),
        fill: function(d) {
          if (d.x === "Sum" || d.y === "Sum") {
            return '#fff';
          } else if (d.x === d.y) {
            return S.c(A.c(d));
          } else {
            return S.c2(A.c(d));
          }
        }
      });
      cells.exit().remove();
      tooltipFn = function(d) {
        var prefix;
        if (d.x === 'Sum' || d.y === 'Sum') {
          return "Count of " + d.y + ": " + d.Freq;
        }
        if (d.x === d.y) {
          prefix = 'correctly';
        } else {
          prefix = 'incorrectly';
        }
        return (d3.format('%.2f')(d.c)) + " of <b>" + d.y + "</b> are <br/>  " + prefix + " classified as <b>" + d.x + "</b>";
      };
      cells.filter(function(d) {
        return d.y !== 'Sum';
      }).call(attachTooltip, {
        html: tooltipFn
      });
      labels = layers.get('cells').selectAll('.hlabel').data(data);
      labels.enter().append('text.hlabel');
      labels.attr({
        x: function(d) {
          return S.x(A.x(d)) + S.x.rangeBand() / 2;
        },
        y: function(d) {
          return S.y(A.y(d)) + S.y.rangeBand() / 2;
        },
        "text-anchor": "middle",
        "alignment-baseline": "middle",
        "pointer-events": "none",
        "fill-opacity": 0.8,
        "font-size": opts.fontSize || 10
      });
      labels.text(function(d) {
        return d.Freq;
      });
      xylabels = layers.get('cells').selectAll(".xylabels").data(['Actual', 'Predicted']);
      xylabels.enter().append('text.xylabels');
      xylabels.attr({
        "text-anchor": "middle",
        "alignment-baseline": "middle",
        x: function(d, i) {
          if (i === 0) {
            return -H_ / 2;
          } else {
            return W_ / 2;
          }
        },
        y: function(d, i) {
          if (i === 0) {
            return -opts.margin.left + 10;
          } else {
            return H_ + 20;
          }
        },
        transform: function(d, i) {
          if (i === 0) {
            return "rotate(270)";
          } else {
            return "rotate(0)";
          }
        }
      });
      xylabels.text(function(d) {
        return d;
      });
      accuracy = layers.get('accuracy').selectAll('g.accuracy').data(data.filter(function(d) {
        return d.x === d.y;
      }));
      accEnter = accuracy.enter().append('g.accuracy');
      accuracy.exit().remove();
      txtheader = layers.get('accuracy').selectAll('text.header').data([{}]);
      txtheader.enter().append('text.header');
      txtheader.attr({
        x: S.x.rangeExtent()[1] + 5,
        y: -13,
        "font-size": 12,
        "text-anchor": "start",
        "class": "header"
      }).text("Accuracy");
      accEnter.append('rect');
      accuracy.select('rect').attr({
        x: S.x.rangeExtent()[1] + 5,
        y: function(d, i) {
          return S.y(A.y(d));
        },
        height: S.y.rangeBand(),
        width: function(d, i) {
          return d.c * 50;
        },
        fill: 'rgb(0, 158, 115)',
        "fill-opacity": 0.6,
        stroke: '#fff'
      });
      tooltipFn2 = function(d) {
        return (d3.format('%.1f')(d.c)) + " of " + d.x + " were </br>\ncorrectly classified";
      };
      accuracy.call(attachTooltip, {
        html: tooltipFn2
      });
      accEnter.append('text.alabel');
      rectlabel = accuracy.select('text.alabel');
      rectlabel.attr({
        "text-anchor": "start",
        "alignment-baseline": "middle",
        x: function(d, i) {
          return S.x.rangeExtent()[1] + 10;
        },
        y: function(d, i) {
          return S.y(A.y(d)) + S.y.rangeBand() / 2;
        },
        "font-size": 10,
        "class": "alabel",
        "pointer-events": "none"
      });
      rectlabel.text(function(d) {
        return d3.format('%.1f')(d.c);
      });
      yAxis = d3.svg.axis().scale(S.y).orient('left');
      layers.get('y-axis').call(yAxis);
      xAxis = d3.svg.axis().scale(S.x).orient('bottom');
      return layers.get('x-axis').attr("transform", "translate(0, -30)").call(xAxis);
    };
    return skeleton.resizeToFitContainer().on("data", visualize).on("resize", visualize).autoResize(true);
  };

  root.renderHeatMap = function(el, x, width, height) {
    var heatMap, heatplot;
    heatMap = d3Kit.factory.createChart(x.defaults, [], heatMapConstructor);
    return heatplot = new heatMap('#' + el.id).data(x.data);
  };

}).call(this);

