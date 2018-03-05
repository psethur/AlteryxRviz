var acfChart, drawAxes;

drawAxes = function() {
  var defaults, exports, opts;
  defaults = {
    scale: "",
    xlab: "x",
    ylab: "y"
  };
  opts = extend(defaults, arguments[0]);
  exports = function(sel) {
    var xAxis, yAxis;
    xAxis = d3.svg.axis().scale(opts.scale.x.nice()).orient('bottom');
    sel.append('g').attr('class', 'x axis').attr('transform', "translate(0, " + (opts.scale.y.range()[0]) + ")").call(xAxis);
    yAxis = d3.svg.axis().scale(opts.scale.y).orient('left').ticks(5).tickSize(-opts.scale.x.range()[1]);
    sel.append('g').attr('class', 'y axis').call(yAxis);
    sel.append("text.x.label").style("font-size", 12).text(opts.xlab).attr({
      x: opts.scale.x.range()[1],
      y: opts.scale.y.range()[0] + 30
    });
    return sel.append("text.y.label").style("font-size", 12).text(opts.ylab).attr({
      x: 0,
      dx: -20,
      dy: -20,
      y: 0
    });
  };
  exports.opts = opts;
  createAccessors(exports);
  return exports;
};

acfChart = d3Kit.factory.createChart({
  margin: {
    left: 40,
    right: 40,
    bottom: 40,
    top: 40
  },
  initialHeight: 200,
  initialWidth: 'auto'
}, ['click'], function(skeleton) {
  var S, layers, visualize;
  S = {
    x: d3.scale.linear().nice(),
    y: d3.scale.linear().nice()
  };
  layers = skeleton.getLayerOrganizer();
  layers.create(['x-axis', 'y-axis', 'x-label', 'h-line', 'lines']);
  visualize = d3Kit.helper.debounce((function() {
    var data, hline, hlineAttrs, line, lineFn, options, rng, sel, tableFn, values, xAxis, xAxisFn, xLabel, yAxis, yAxisFn;
    options = skeleton.options();
    data = skeleton.data();
    values = data.data.map(function(d) {
      return [
        {
          x: d.x,
          y: d.y1
        }, {
          x: d.x,
          y: d.y2
        }
      ];
    });
    S.x.domain([
      0, d3.max(data.data, function(d) {
        return d.x;
      }) + 2
    ]).range([0, skeleton.getInnerWidth()]);
    S.y.domain(data.ydomain).range([skeleton.getInnerHeight(), 0]);
    xAxisFn = d3.svg.axis().scale(S.x).ticks(skeleton.getInnerWidth() / 25).orient('bottom');
    xAxis = layers.get('x-axis');
    xAxis.attr('transform', "translate(0, " + (S.y.range()[0]) + ")").call(xAxisFn);
    yAxisFn = d3.svg.axis().scale(S.y).orient('left').ticks(5).tickSize(-S.x.range()[1]);
    yAxis = layers.get('y-axis');
    yAxis.call(yAxisFn);
    sel = layers.get('lines');
    xLabel = sel.selectAll("text.x.label").data([{}]);
    xLabel.enter().append("text.x.label");
    xLabel.style("font-size", 12).text(options.xlab || 'Lag').attr({
      x: S.x.range()[1],
      y: S.y.range()[0] + 30
    });
    sel.append("text.y.label").style("font-size", 12).text(options.ylab || 'ACF').attr({
      x: 0,
      dx: -20,
      dy: -20,
      y: 0
    });
    lineFn = d3.svg.line().x(function(d, i) {
      return S.x(d.x);
    }).y(function(d) {
      return S.y(d.y);
    });
    line = sel.selectAll(".line").data(values);
    line.enter().append("path.line");
    line.attr("d", lineFn).attr(options.line || {
      stroke: 'steelblue'
    });
    tableFn = function(d) {
      var y;
      y = d[0].y !== 0 ? d[0].y : d[1].y;
      return d3.table({
        lag: d[0].x,
        ac: y
      });
    };
    sel.selectAll('.line').call(attachTooltip, {
      html: tableFn
    });
    hlineAttrs = {
      "stroke-width": 1,
      stroke: "steelblue",
      "stroke-dasharray": "5,2"
    };
    hline = layers.get('h-line').selectAll(".hline").data(options.hline || [-0.2, 0.2]);
    hline.enter().append("line.hline");
    rng = S.x.range();
    hline.attr({
      x1: rng[0],
      x2: rng[1],
      y1: function(d) {
        return S.y(d);
      },
      y2: function(d) {
        return S.y(d);
      }
    });
    return hline.attr(extend(hlineAttrs, options.hlineAttrs));
  }), 30);
  return skeleton.on('data', visualize).on('resize', visualize).autoResize(true);
});
