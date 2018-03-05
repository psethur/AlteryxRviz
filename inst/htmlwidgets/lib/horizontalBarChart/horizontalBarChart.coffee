root = exports ? this
horizontalBarChartConstructor = (skeleton) ->
  layers = skeleton.getLayerOrganizer()
  S =
    x: d3.scale.linear()
    y: d3.scale.ordinal()
  A =
    x: (d) -> d.x
    y: (d) -> d.y
  layers.create(['x-axis', 'y-axis', 'hbars', 'hbarlabels'])
  visualize = ->
    data = skeleton
      .data().value
      .sort (a, b) -> d3.descending(a.x, b.x)
    opts = skeleton.options()
    H = skeleton.getInnerHeight()
    W = skeleton.getInnerWidth()
    console.log(W)
    if (W <= 0)
      return
    S.x.range([0, W])
     .domain([0, d3.max(data, A.x)])
     .nice()
    S.y.rangeRoundBands([0, H], 0.1)
     .domain(data.map(A.y))

    hbars = layers.get('hbars').selectAll('rect.hbar').data(data)
    hbars.enter().append('rect.hbar')
      .attr
        x: 0
        width: 0
        height: S.y.rangeBand()
    hbars
      .transition().duration(750)
      .attr
        y: (d) -> S.y A.y(d)
        width: (d) -> S.x A.x(d)
        fill: 'steelblue'

    hbars.exit().remove()

    hbarlabel = layers.get('hbarlabels')
      .selectAll('text.hbarlabel').data(data)
    hbarlabel.enter().append('text.hbarlabel')
      .attr
        x: 0
        "fill-opacity": 0.7
        y: (d) -> S.y(A.y(d)) + S.y.rangeBand()/2
        "text-anchor": "start"
        "alignment-baseline": "middle"
        "pointer-events": "none"
    hbarlabel
      .transition().duration(750)
      .attr
         x: (d) -> S.x(A.x(d)) + 5
      .text (d) -> d3.format('.1f')(d.x)


    hbarlabel.exit().remove()

    yAxis = d3.svg.axis().scale(S.y).orient('left')
      .outerTickSize(0)

    layers.get('y-axis').call(yAxis)
    xAxis = d3.svg.axis().scale(S.x).orient('bottom')
      .ticks(Math.floor(W/70))
      #.tickSize(-H)
    layers.get('x-axis')
      .attr("transform", "translate(0, #{H})")
      .call(xAxis)
  skeleton
    .resizeToFitContainer()
    .on("data", visualize)
    .on("resize", visualize)
    .autoResize(true)


root.renderHorizontalBarChart = (el, x, width, height) ->
  horizontalBarChart = d3Kit.factory.createChart(
    x.defaults, [], horizontalBarChartConstructor
  )
  barchart = new horizontalBarChart('#' + el.id).data(x.data)
