var d3k, d3u, dummyData, error, foo, foo2, infoc, renderInfoBox;

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

foo = function(sel, data) {
  return sel.append('ul.list-inline.metrics').selectAll('li').data(data).enter().append('li.preview').style('position', 'relative').classed("active", function(d, i) {
    return i === 0;
  }).append('small').style('position', 'relative').attr({
    "class": function(d, i) {
      return "measure item-" + d;
    },
    measure: function(d) {
      return d;
    }
  }).text(function(d) {
    return d;
  });
};

d3u = d3u || {};

d3u.hovercard = function() {
  var exports;
  return exports = function(selection) {
    return selection.each(function(data) {
      var det, main;
      main = d3.select(this);
      det = main.selectAll('.details').data([data]);
      d3.select(this).on("mouseover", function() {
        main.select(".measure").style('z-index', 100);
        det.enter().append("span").attr("class", "details");
        det.html(function(d) {
          return d;
        });
        return det.transition().duration(500).style('opacity', 1);
      });
      return d3.select(this).on("mouseout", function() {
        main.select(".measure").style('z-index', 1);
        det.transition().duration(500).style('opacity', 0);
        return det.remove();
      });
    });
  };
};

error = {
  MAE: {
    value: 45,
    title: "Mean Absolute Error",
    definition: '<p style="text-align:justify">Mean Absolute Error is the average over the verification sample of the absolute values of the differences between forecast and the corresponding observation. The MAE is a linear score which means that all the individual differences are weighted equally in the average.</p>'
  },
  MAPE: {
    value: 20,
    title: "Mean Abs Perc Error",
    definition: '<p style="text-align:justify">Mean Absolute Percentage Error is the average over the verification sample of the absolute values of the <b>percent</b> differences between forecast and the corresponding observation.</p>'
  },
  MASE: {
    value: 30,
    title: "Mean Abs Scaled Error",
    definition: '<p style="text-align:justify;"> Mean Absolute Scaled Error is the average over the verification sample of the absolute values of the ratio of the forecast error to the average forecast error of the one-step naive forecast<p>'
  },
  RMSE: {
    value: 40,
    title: "Root Mean Square Error",
    definition: '<p style="text-align:justify;"> Root Mean Squared Error is the average over the verification sample of the absolute values of the ratio of the forecast error to the average forecast error of the one-step naive forecast<p>'
  },
  MPE: {
    value: 20,
    title: "Mean Percent Error",
    definition: '<p style="text-align:justify;"> Mean Percent Error is the average over the verification sample of the absolute values of the ratio of the forecast error to the average forecast error of the one-step naive forecast<p>'
  }
};

infoc = {
  AIC: {
    value: 1813,
    title: "Akaike Info. Criterion",
    definition: '<p style="text-align:justify">Mean Absolute Error is the average over the verification sample of the absolute values of the differences between forecast and the corresponding observation. The MAE is a linear score which means that all the individual differences are weighted equally in the average.</p>'
  },
  AICc: {
    value: 1819,
    title: "Mean Abs Perc Error",
    definition: '<p style="text-align:justify">Mean Absolute Percentage Error is the average over the verification sample of the absolute values of the <b>percent</b> differences between forecast and the corresponding observation.</p>'
  },
  BIC: {
    value: 1856,
    title: "Mean Abs Scaled Error",
    definition: '<p style="text-align:justify;"> Mean Absolute Scaled Error is the average over the verification sample of the absolute values of the ratio of the forecast error to the average forecast error of the one-step naive forecast<p>'
  }
};

foo2 = function() {
  var exports;
  return exports = function(selection) {
    return selection.each(function(data) {
      var cols;
      cols = d3.select(this);
      return cols.each(function(d, i) {
        var definitions, k, main, myPanel, notes, stage, statistic;
        k = Object.keys(d);
        main = d3.select(this);
        myPanel = d3k.panel().panels(['stage', 'notes']);
        main.datum([d]).call(myPanel);
        stage = main.select('.chart-stage');
        stage.style('text-align', 'center').append('span.measure2').text(d[k[0]].title);
        statistic = stage.append("div.statistic");
        statistic.append('span.number').text(d[k[0]].value);
        definitions = Object.keys(d).map(function(d_) {
          return d[d_].definition;
        });
        notes = main.select('.chart-notes');
        notes.call(foo, Object.keys(d));
        notes.selectAll('.preview').data(definitions).call(d3u.hovercard());
        return notes.selectAll(".preview").on("click", function() {
          var m;
          notes.selectAll(".preview").classed('active', false);
          d3.select(this).classed('active', true);
          m = d3.select(this).select(".measure").attr('measure');
          statistic.select('.number').text(d[m].value);
          return stage.select('.measure2').text(d[m].title);
        });
      });
    });
  };
};

renderInfoBox = function(el, x) {
  var cols;
  cols = d3.select(el).selectAll(".kpanel").data(x.data);
  cols.enter().append("div." + x.div + ".kpanel");
  return cols.call(foo2());
};

dummyData = {
  data: [error, infoc],
  div: "col-sm-5.col-xs-5.col-md-4"
};

// ---
// generated by coffee-script 1.9.2
