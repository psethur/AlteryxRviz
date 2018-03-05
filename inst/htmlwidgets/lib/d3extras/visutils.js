var attachTooltip, createAccessors, createSVG, extend, responsify, updateOpts;

d3.uniq = function(data, fun) {
  var v_;
  if (typeof fun === 'function') {
    v_ = data.map(fun);
  } else {
    v_ = data.map(function(d) {
      return d[fun];
    });
  }
  return d3.set(v_).values();
};

d3.bs = d3.bs || {};

d3.bs.progress = function() {
  var exports;
  return exports = function(selection) {
    return selection.each(function(data) {
      var items, pbar;
      pbar = d3.select(this).selectAll(".progress").data([{}]);
      pbar.enter().append("div.progress.dataquality");
      items = pbar.selectAll('div.progress-bar').data(data);
      items.enter().append('div.progress-bar');
      return items.attr({
        "class": function(d) {
          return "progress-bar progress-bar-" + d.key;
        },
        role: "progressbar",
        "data-toggle": "tooltip",
        "title": function(d) {
          return d.value + "% " + d.status;
        }
      }).style({
        width: function(d) {
          return d.value + "%";
        },
        opacity: 0.9
      });
    });
  };
};

createAccessors = function(visExport) {
  var n;
  for (n in visExport.opts) {
    if (!visExport.opts.hasOwnProperty(n)) {
      continue;
    }
    visExport[n] = (function(n) {
      return function(v) {
        if (arguments.length) {
          visExport.opts[n] = v;
          return this;
        } else {
          return visExport.opts[n];
        }
      };
    })(n);
  }
};

extend = function(defaults, options) {
  var extended, prop;
  extended = {};
  prop = void 0;
  for (prop in defaults) {
    prop = prop;
    if (Object.prototype.hasOwnProperty.call(defaults, prop)) {
      extended[prop] = defaults[prop];
    }
  }
  for (prop in options) {
    prop = prop;
    if (Object.prototype.hasOwnProperty.call(options, prop)) {
      extended[prop] = options[prop];
    }
  }
  return extended;
};

d3.ui = d3.ui || {};

d3.ui.panel = function() {
  var defaults, exports, opts;
  defaults = {
    panels: ["heading", "body"],
    type: "default"
  };
  opts = extend(arguments[0], defaults);
  exports = function(selection) {
    return selection.each(function(data) {
      var panel, panelEnter;
      panel = d3.select(this).selectAll("div.panel").data(data);
      panelEnter = panel.enter().append("div.panel.panel-" + opts.type);
      opts.panels.forEach(function(d) {
        return panelEnter.append("div.panel-" + d);
      });
      return panel;
    });
  };
  exports.opts = opts;
  createAccessors(exports);
  return exports;
};

attachTooltip = function(sel, opts) {
  var tip;
  tip = d3.tip().attr('class', 'd3-tip').html(opts.html);
  d3.select(sel.node().parentNode).call(tip);
  sel.on("mouseover", tip.show);
  sel.on("mouseout", tip.hide);
  return sel;
};

d3.table = function(data, title) {
  var table;
  table = ["<table>"];
  d3.entries(data).forEach(function(d) {
    return table.push("<tr><td class='key'>" + d.key + "</td><td>&nbsp&nbsp</td><td class='value'>" + d.value + "</td></tr>");
  });
  return table.join("") + "</table>";
};

d3.selection.prototype.dataAppend = function(name, data) {
  var x;
  x = this.selectAll(name).data(data);
  x.enter().append(name);
  return x;
};

d3.selection.prototype.innerWidth = function() {
  var left, parent, right, width;
  parent = d3.select(this.node().parentNode);
  width = parseInt(parent.style('width'), 10);
  left = parseInt(parent.style('padding-left'), 10);
  right = parseInt(parent.style('padding-right'), 10);
  return width - left - right;
};

d3.selection.prototype.innerHeight = function() {
  var bottom, parent, top, width;
  parent = d3.select(this.node().parentNode);
  width = parseInt(parent.style('height'), 10);
  top = parseInt(parent.style('padding-top'), 10);
  bottom = parseInt(parent.style('padding-bottom'), 10);
  return height - top - bottom;
};

responsify = function() {
  var aspect, height, resize, svg, width;
  svg = this;
  width = parseInt(svg.style("width"));
  height = parseInt(svg.style("height"));
  aspect = width / height;
  resize = function() {
    var targetWidth;
    targetWidth = svg.innerWidth();
    svg.attr("width", targetWidth);
    return svg.attr("height", Math.round(targetWidth / aspect));
  };
  d3.select(window).on("resize." + (svg.attr('id')), resize);
  return this.attr({
    viewBox: "0 0 " + width + " " + height,
    preserveAspectRatio: "xMinYMid"
  }).call(resize);
};

updateOpts = function(sel, opts) {
  opts.width = parseInt(sel.style('width')) - opts.m.l - opts.m.r;
  opts.height = parseInt(sel.style('height')) - opts.m.t - opts.m.b;
  return sel;
};

d3.random_id = function(prefix) {
  prefix || (prefix = '');
  return prefix + (Math.random() * 1e16).toFixed(0);
};

createSVG = function(sel, width, height) {
  var svg_;
  svg_ = sel.selectAll('svg').data([{}]);
  svg_.enter().append('svg');
  return svg_.attr('width', width).attr('height', height).attr('id', function(d, i) {
    return d3.random_id('svg');
  }).call(responsify);
};