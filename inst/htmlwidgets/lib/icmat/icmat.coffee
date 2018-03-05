root = exports ? this
heatMapConstructor = (skeleton) ->
  layers = skeleton.getLayerOrganizer()
  S =
    x: d3.scale.ordinal()
    y: d3.scale.ordinal()
    c: d3.scale.linear()
  A =
    x: (d) -> d.x
    y: (d) -> d.y
    c: (d) -> d.c
  layers.create(['cells', 'y-axis', 'x-axis', 'accuracy'])
  visualize = ->
    data = skeleton.data()
    opts = skeleton.options()
    x = Math.min(
      skeleton.getInnerWidth(), skeleton.getInnerHeight()
    )
    W_ = x; H_ = x;
    S.x.rangeRoundBands([0, W_]).domain data.map(A.x)
    S.y.rangeRoundBands([0, H_]).domain data.map(A.y)
    #S.c.range(['crimson', 'white', 'purple'])
    #  .domain [-1, 0, 1]
    S.c.range(['white', 'rgb(0, 158, 115)'])
      .domain([0, 1])
    S.c2 = S.c.copy()
      .range(['white', 'rgb(213, 94, 0)'])
    cells = layers.get('cells').selectAll('.cell')
      .data(data)
    cells.enter().append('rect.cell')
    cells.attr
      x: (d) -> S.x A.x(d)
      y: (d) -> S.y A.y(d)
      width: S.x.rangeBand()
      height: S.y.rangeBand()
      fill: (d) ->
        if d.x is "Sum" or d.y is "Sum"
            '#fff'
        else if (d.x is d.y)
          S.c A.c(d)
        else
          S.c2 A.c(d)
    cells.exit().remove()
    tooltipFn = (d) ->
      if (d.x is 'Sum' or d.y is 'Sum')
        return "Count of #{d.y}: #{d.Freq}"
      if (d.x is d.y)
        prefix = 'correctly'
      else
        prefix = 'incorrectly'
      """
      #{d3.format('%.2f')(d.c)} of <b>#{d.y}</b> are <br/>  #{prefix} classified as <b>#{d.x}</b>
      """

    cells
      .filter((d) -> d.y != 'Sum')
      .call attachTooltip, {html: tooltipFn}

    labels = layers.get('cells').selectAll('.hlabel')
      .data(data)
    labels.enter().append('text.hlabel')
    labels.attr
      x: (d) -> S.x(A.x(d)) + S.x.rangeBand()/2
      y: (d) -> S.y(A.y(d)) + S.y.rangeBand()/2
      "text-anchor": "middle"
      "alignment-baseline": "middle"
      "pointer-events": "none"
      "fill-opacity": 0.8
      "font-size": opts.fontSize || 10
    labels.text (d) -> d.Freq

    xylabels = layers.get('cells').selectAll(".xylabels")
      .data(['Actual', 'Predicted'])
    xylabels.enter().append('text.xylabels')
    xylabels.attr
      "text-anchor": "middle"
      "alignment-baseline": "middle"
      x: (d, i) -> if (i is 0) then -H_/2 else W_/2
      y: (d, i) -> if (i is 0) then (-opts.margin.left + 10) else H_ + 20
      transform: (d, i) ->
        if (i is 0) then "rotate(270)" else "rotate(0)"
    xylabels.text (d) -> d

    accuracy = layers.get('accuracy')
      .selectAll('g.accuracy')
      .data(data.filter (d) -> d.x is d.y)

    accEnter = accuracy.enter().append('g.accuracy')

    accuracy.exit().remove()

    txtheader = layers.get('accuracy')
      .selectAll('text.header')
      .data([{}])
    txtheader.enter().append('text.header')
    txtheader
      .attr
        x: S.x.rangeExtent()[1] + 5
        y: -13
        "font-size": 12
        "text-anchor": "start"
        "class": "header"
      .text("Accuracy")

    accEnter.append('rect')
    accuracy.select('rect').attr
      x: S.x.rangeExtent()[1] + 5
      y: (d, i) -> S.y A.y(d)
      height: S.y.rangeBand()
      width: (d, i) -> d.c*50
      fill: 'rgb(0, 158, 115)'
      "fill-opacity": 0.6
      stroke: '#fff'

    tooltipFn2 = (d) ->
      """
      #{d3.format('%.1f')(d.c)} of #{d.x} were </br>
      correctly classified
      """
    accuracy.call attachTooltip, {html: tooltipFn2}

    accEnter.append('text.alabel')
    rectlabel = accuracy.select('text.alabel')
    rectlabel.attr
      "text-anchor": "start"
      "alignment-baseline": "middle"
      x: (d, i) -> S.x.rangeExtent()[1] + 10
      y: (d, i) -> S.y(A.y(d)) + S.y.rangeBand()/2
      "font-size": 10
      "class": "alabel"
      "pointer-events": "none"

    rectlabel.text (d) -> d3.format('%.1f')(d.c)

    yAxis = d3.svg.axis().scale(S.y).orient('left')
    layers.get('y-axis')
      .call(yAxis)
    xAxis = d3.svg.axis().scale(S.x).orient('bottom')
    layers.get('x-axis')
      .attr("transform", "translate(0, -30)")
      .call(xAxis)
  skeleton
    .resizeToFitContainer()
    .on("data", visualize)
    .on("resize", visualize)
    .autoResize(true)

root.renderHeatMap = (el, x, width, height) ->
  heatMap = d3Kit.factory.createChart(
    x.defaults, [], heatMapConstructor
  )
  heatplot = new heatMap('#' + el.id).data(x.data)
