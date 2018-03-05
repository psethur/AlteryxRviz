root = exports ? this
d3u = d3u || {}
d3u.hovercard = ->
  exports = (selection) ->
    selection.each (data) ->
      main = d3.select(this);
      det = main.selectAll('.details').data([data]);
      d3.select(this).on "mouseover", ->
        main.select(".measure").style('z-index', 100);
        det.enter().append("span").attr("class", "details");
        det.html (d) -> d
        det.transition().duration(500).style('opacity', 1);
      d3.select(this).on "mouseout", ->
        main.select(".measure").style('z-index', 1);
        det.transition().duration(500).style('opacity', 0);
        det.remove()
  exports
root.makeHistogram = (el, data) ->
    makeTipData = (d) ->
       title: "#{d.x} to #{d.x + d.dx}<br/>#{d.y} instances"
       theme: "kodama"
    histConstructor = (skeleton) ->
      S =
        x: d3.scale.linear()
        y: d3.scale.linear()
      A =
        x: (d) -> d.x
        y: (d) -> d.y
      L = skeleton.getLayerOrganizer()
      L.create(['x-axis', 'y-axis', 'bars'])
      visualize = ->
        O = skeleton.options()
        W = skeleton.getInnerWidth()
        H = skeleton.getInnerHeight()
        console.log H
        data_ = skeleton.data()

        #S.x.range([0, W]).domain d3.extent(data_)
        S.x.range([0, W]).domain([0, d3.max(data_)])
        nbins = (x) ->
          Math.ceil(Math.log(x.length)/Math.log(2) + 1)
        histData = d3.layout.histogram()
          .bins(S.x.ticks(O.bins || nbins(data_)))(data_)


        S.y.range([H, 0]).domain [0, d3.max(histData, A.y)]
        console.log histData
        console.log d3.extent(histData, A.y)
        bars = L.get('bars')
          .selectAll("rect")
          .data(histData)
        bars.enter().append("rect")
        bars.exit().remove()
        bars.attr
          transform: (d) -> "translate(#{S.x(A.x(d))}, #{S.y(A.y(d))})"
          x: 1
          width: (d) -> S.x(histData[1].x) - S.x(histData[0].x) - 1
          height: (d) -> H - S.y(A.y(d))
          fill: "steelblue"

        histTooltip = (d, i) ->
            """
            <div class='histtip'>
            #{d.x} to #{d.x + d.dx}<br/>
            #{d.y} instances
            </div>
            """
        #bars.call attachTooltip, {html: histTooltip}
        bars.call d3.kodama.tooltip().format(makeTipData)
        drawAxes = (xAxis, yAxis, S) ->
          xAxisFn = d3.svg.axis()
            .scale(S.x)
            .orient('bottom')
            .outerTickSize(0)
          xAxis
            .attr('transform', "translate(0, #{S.y.range()[0]})")
            .call(xAxisFn)
          yAxisFn = d3.svg.axis()
            .scale(S.y.nice())
            .orient('left')
            .ticks(5)
            .outerTickSize(0)
            .tickSize(-S.x.range()[1])
          yAxis
            .call(yAxisFn)
        drawAxes(
           L.get('x-axis'), L.get('y-axis'), S
        )
      skeleton
        .autoResize(true)
        .on("data", visualize)
        .on("resize", visualize)

    defaults =
      margin: {left: 20, right: 20, bottom: 20, top: 20},
      initialHeight: 200
      initialWidth: "auto"
    histChart = d3Kit.factory.createChart(
       defaults, [], histConstructor
    )

    addFilterButtons = (id, data, mychart) ->
      k = Object.keys(data)
      console.log(k)
      ul = d3.select(id)
        .selectAll("ul")
        .data([k])
      console.log ul
      ul.enter().append('ul.infobox.list-inline')
      li = ul.selectAll("li").data(k)
      li.enter().append("li")
      li.classed("active", (d, i) -> i is 0)
        .text((d) -> d)
        .on "click", ->
          li.classed("active", false)
          d3.select(@).classed("active", true)
          dist = d3.select(@).text()
          mychart.data(data[dist])
    mychart = new histChart(el)
      .data(data[Object.keys(data)[0]])

    addFilterButtons(el, data, mychart)
    mychart
