(function() {
  var d3u, root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  d3u = d3u || {};

  d3u.hovercard = function() {
    var exports;
    exports = function(selection) {
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
    return exports;
  };

  root.makeHistogram = function(el, data) {
    var addFilterButtons, defaults, histChart, histConstructor, makeTipData, mychart;
    makeTipData = function(d) {
      return {
        title: d.x + " to " + (d.x + d.dx) + "<br/>" + d.y + " instances",
        theme: "kodama"
      };
    };
    histConstructor = function(skeleton) {
      var A, L, S, visualize;
      S = {
        x: d3.scale.linear(),
        y: d3.scale.linear()
      };
      A = {
        x: function(d) {
          return d.x;
        },
        y: function(d) {
          return d.y;
        }
      };
      L = skeleton.getLayerOrganizer();
      L.create(['x-axis', 'y-axis', 'bars']);
      visualize = function() {
        var H, O, W, bars, data_, drawAxes, histData, histTooltip, nbins;
        O = skeleton.options();
        W = skeleton.getInnerWidth();
        H = skeleton.getInnerHeight();
        console.log(H);
        data_ = skeleton.data();
        S.x.range([0, W]).domain([0, d3.max(data_)]);
        nbins = function(x) {
          return Math.ceil(Math.log(x.length) / Math.log(2) + 1);
        };
        histData = d3.layout.histogram().bins(S.x.ticks(O.bins || nbins(data_)))(data_);
        S.y.range([H, 0]).domain([0, d3.max(histData, A.y)]);
        console.log(histData);
        console.log(d3.extent(histData, A.y));
        bars = L.get('bars').selectAll("rect").data(histData);
        bars.enter().append("rect");
        bars.exit().remove();
        bars.attr({
          transform: function(d) {
            return "translate(" + (S.x(A.x(d))) + ", " + (S.y(A.y(d))) + ")";
          },
          x: 1,
          width: function(d) {
            return S.x(histData[1].x) - S.x(histData[0].x) - 1;
          },
          height: function(d) {
            return H - S.y(A.y(d));
          },
          fill: "steelblue"
        });
        histTooltip = function(d, i) {
          return "<div class='histtip'>\n" + d.x + " to " + (d.x + d.dx) + "<br/>\n" + d.y + " instances\n</div>";
        };
        bars.call(d3.kodama.tooltip().format(makeTipData));
        drawAxes = function(xAxis, yAxis, S) {
          var xAxisFn, yAxisFn;
          xAxisFn = d3.svg.axis().scale(S.x).orient('bottom').outerTickSize(0);
          xAxis.attr('transform', "translate(0, " + (S.y.range()[0]) + ")").call(xAxisFn);
          yAxisFn = d3.svg.axis().scale(S.y.nice()).orient('left').ticks(5).outerTickSize(0).tickSize(-S.x.range()[1]);
          return yAxis.call(yAxisFn);
        };
        return drawAxes(L.get('x-axis'), L.get('y-axis'), S);
      };
      return skeleton.autoResize(true).on("data", visualize).on("resize", visualize);
    };
    defaults = {
      margin: {
        left: 20,
        right: 20,
        bottom: 20,
        top: 20
      },
      initialHeight: 200,
      initialWidth: "auto"
    };
    histChart = d3Kit.factory.createChart(defaults, [], histConstructor);
    addFilterButtons = function(id, data, mychart) {
      var k, li, ul;
      k = Object.keys(data);
      console.log(k);
      ul = d3.select(id).selectAll("ul").data([k]);
      console.log(ul);
      ul.enter().append('ul.infobox.list-inline');
      li = ul.selectAll("li").data(k);
      li.enter().append("li");
      return li.classed("active", function(d, i) {
        return i === 0;
      }).text(function(d) {
        return d;
      }).on("click", function() {
        var dist;
        li.classed("active", false);
        d3.select(this).classed("active", true);
        dist = d3.select(this).text();
        return mychart.data(data[dist]);
      });
    };
    mychart = new histChart(el).data(data[Object.keys(data)[0]]);
    addFilterButtons(el, data, mychart);
    return mychart;
  };

}).call(this);

