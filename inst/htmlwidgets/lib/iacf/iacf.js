var d3k, d3t, d3u, drawAxes;

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
    xAxis = d3.svg.axis().scale(opts.scale.x).orient('bottom');
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

d3t = d3t || {};

d3t.acfplot = function() {
  var defaults, exports, opts;
  defaults = {
    m: {
      l: 40,
      r: 40,
      b: 40,
      t: 40
    },
    height: 200
  };
  opts = extend(defaults, arguments[0]);
  exports = function(selection) {
    return selection.each(function(data) {
      var S, hline, hlines1, line, lineFn, main, myAxis, sel, svg, tableFn, values;
      main = d3.select(this);
      createSVG(main, '100%', opts.height);
      sel = main.select("svg");
      opts.width = parseInt(sel.style('width')) - opts.m.l - opts.m.r;
      opts.height = parseInt(sel.style('height')) - opts.m.t - opts.m.b;
      S = {
        x: d3.scale.linear().range([0, opts.width]),
        y: d3.scale.linear().range([opts.height, 0])
      };
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
      ]);
      S.y.domain(data.ydomain);
      lineFn = d3.svg.line().x(function(d, i) {
        return S.x(d.x);
      }).y(function(d) {
        return S.y(d.y);
      });
      svg = sel.attr('width', opts.width + opts.m.l + opts.m.r).attr('height', opts.height + opts.m.t + opts.m.b).append("g").attr({
        "transform": "translate(" + opts.m.l + ", " + opts.m.t + ")"
      });
      myAxis = drawAxes().scale(S).xlab(data.xlab).ylab(data.ylab);
      svg.call(myAxis);
      line = svg.selectAll(".line").data(values);
      line.enter().append("path.line");
      line.attr("d", lineFn);
      tableFn = function(d) {
        var y;
        y = d[0].y !== 0 ? d[0].y : d[1].y;
        return d3.table({
          lag: d[0].x,
          ac: y
        });
      };
      svg.selectAll('.line').call(attachTooltip, {
        html: tableFn
      });
      hline = d3u.hline().scale(S);
      hlines1 = svg.append("g.hlines").datum(data.hlines).call(hline.stroke('blue'));
      /*
      hlines1.on("mouseover", function(d) {
        return svg.select(".y.label").text("ACF  No significant autocorrelation between these values " + d);
      });
      hlines1.on("mouseout", function(d) {
        return svg.select(".y.label").text(data.ylab);
      });
      */
      return svg.append("g.hlines").datum([0]).call(d3u.hline({
        stroke: "gray",
        "stroke-dasharray": "5,0",
        scale: S
      }));
    });
  };
  exports.opts = opts;
  createAccessors(exports);
  return exports;
};

d3u = d3u || {};

d3u.hline = function() {
  var defaults, exports, opts;
  defaults = {
    scale: "",
    "stroke-width": 1,
    stroke: "steelblue",
    "stroke-dasharray": "5,2"
  };
  opts = extend(defaults, arguments[0]);
  exports = function(selection) {
    return selection.each(function(data) {
      var line, rng, sel;
      sel = d3.select(this);
      line = sel.selectAll(".hline").data(data);
      line.enter().append("line.hline");
      rng = opts.scale.x.range();
      line.attr({
        x1: rng[0],
        x2: rng[1],
        y1: function(d) {
          return opts.scale.y(d);
        },
        y2: function(d) {
          return opts.scale.y(d);
        }
      });
      return line.attr(opts);
    });
  };
  exports.opts = opts;
  createAccessors(exports);
  return exports;
};

d3k = d3k || {};

d3k.panel = function() {
  var defaults, exports, opts;
  defaults = {
    panels: ["title", "stage", "notes"],
    title: "",
    stage: "",
    notes: ""
  };
  opts = extend(arguments[0], defaults);
  exports = function(selection) {
    return selection.each(function(data) {
      var panel, panelEnter;
      panel = d3.select(this).selectAll("div.chart-wrapper").data(data);
      panelEnter = panel.enter().append("div.chart-wrapper");
      return opts.panels.forEach(function(d) {
        return panelEnter.append("div.chart-" + d).html(opts[d]);
      });
    });
  };
  exports.opts = opts;
  createAccessors(exports);
  return exports;
};
