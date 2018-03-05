(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.tablechart = function() {
    var exports;
    return exports = function(selection) {
      return selection.each(function(data) {
        var bars, barwidth, h, headers, panel, question, svg, table2, tbody, td, thead, tip, tr, viz, x;
        h = Object.keys(data.measures[0]);
        x = h.map(function(y) {
          var m_;
          m_ = d3.max(data.measures, function(d) {
            return d[y];
          });
          return data.measures.map(function(d) {
            return d[y] / m_;
          });
        });
        headers = d3.merge([["Model"], h]);
        viz = d3.select(this);
        //panel = viz.append("div").attr("class", "panel panel-default");
        panel = viz.append("div").attr("class", "chart-wrapper");
        //panel.append("div").attr("class", "panel-heading").append("h4").text(data.heading);
        panel.append("div").attr("class", "chart-title").html(data.heading)
        table2 = panel.append("div").attr("class", "table-responsive").append("table").attr("class", "table table-hover tablechart");
        //panel.append("div").attr("class", "panel-footer").append("small").text(data.footnote);
        panel.append("div").attr("class", "chart-notes").html(data.footnote);
        thead = table2.append("thead");
        tbody = table2.append("tbody");
        question = '';
        thead.append("tr").selectAll("th").data(headers).enter().append("th").html(function(d, i) {
          if (i > 0) {
            return "<span class='header'>" + d + "</span> " + question;
          } else {
            return d;
          }
        });
        tr = tbody.selectAll("tr").data(d3.transpose(x)).enter().append("tr");
        tr.append("th").attr("scope", "row").text(function(d, i) {
          return data.models[i] || "Model " + i;
        }).style("color", "darkgray");
        td = tr.selectAll("td").data(Object).enter().append("td");
        barwidth = parseFloat(td.style("width"));
        svg = td.append("svg").attr("width", "100%").attr("height", 20);
        bars = svg.append("rect").attr("height", 20).attr("width", function(d, i) {
          return d * 95 + "%";
        }).attr("fill", "steelblue");
        tip = d3.tip().attr("class", "d3-tip").direction("e").html(function(d, i) {
          var key, m_;
          key = headers[i + 1];
          m_ = d3.max(data.measures, function(d) {
            return d[key];
          });
          return (d * m_).toFixed(2);
        });
        bars.call(tip);
        bars.on("mouseover", tip.show);
        bars.on("mouseout", tip.hide);
        return table2.selectAll("thead th .header").on("click", function(d, i) {
          var asc;
          d3.selectAll(".header").classed("sorted", false);
          d3.select(this).classed("sorted", true);
          asc = d3.select(this).classed("asc");
          d3.select(this).classed("asc", !asc);
          return tr.sort(function(a, b) {
            if (asc) {
              return b[i] - a[i];
            } else {
              return a[i] - b[i];
            }
          });
        });
      });
    };
  };

}).call(this);
