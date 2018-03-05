graph_box = function(x){
  f = function(x){
    Column(c(xs = 3),
      div(class = 'chart-wrapper',
        div(class = 'chart-stage', style='text-align:center;',
           tags$span(class = 'measure', x$title), tags$br(),
           tags$span(class = 'statistic', x$value, style='font-size:2.5em;')
         )
      )
    )
  }
  popover = function(x, note, ...){
    tags$span(x, ...,
      `data-content` = note,
      `data-placement` = 'bottom',
      `data-toggle` = "popover",
      `data-html` = TRUE,
      `data-container` = 'body',
      style = "cursor:pointer;font-size:16px;"
    )
  }
  f2 = function(x){
    Column(c(xs = 3), style='text-align:center;',
      tags$span(class = 'statistic', x$value, style='font-size:2em;'), tags$br(),
      #hovercard(x$title, x$title)
      #tags$span(class = 'measure', x$title, style='color:gray;')
      popover(x$title, x$definition, class = 'measure',  style='color:gray;')
    )
  }
  box1 = list(
    Diameter = list(
      value = round(diameter(x), 2),
      title = 'Diameter',
      definition = '<p style="text-align:justify;">The diameter of a graph is the greatest distance between any pair of vertices.</p>'
    )
  )
  box2 = list(
    Density = list(
      value = round(graph.density(x), 2),
      title = 'Density',
      definition = '<p style="text-align:justify;">The density of a graph is the ratio between number of edges and the total possible edges</p>'
    )
  )
  box3 = list(
    `Path Length` = list(
      value = round(average.path.length(x), 2),
      title = 'Path Length',
      definition = '<p style="text-align:justify;">The average path length is the mean of all shortest paths computed for every connected pair of vertices.</p>'
    )
  )
  box4 = list(
    `Clustering` = list(
      value = round(transitivity(x), 2),
      title = 'Clustering',
      definition = '<p style="text-align:justify;">The  <a href=https://en.wikipedia.org/wiki/Clustering_coefficient>clustering coefficient</a> is a measure of the degree to which nodes in a graph tend tocluster together.</p>'
    )
  )
  #tagList(f(box1[[1]]), f(box2[[1]]), f(box3[[1]]), f(box4[[1]]))
  note2 = 'These are different network statistics.<br/>
    <b>Diameter: </b> length of the longest geodesic <br/>
    <b>Density: </b> ratio of #edges to no. of possible edges <br/>

  '
  Column(c(xs = 12), id = 'graphbox', div(class = 'chart-wrapper',
      div(class = 'chart-stage', style='text-align:center;',
        f2(box1[[1]]), f2(box2[[1]]), f2(box3[[1]]), f2(box4[[1]])
      )
  ))
  #tagList(f2(box1[[1]]), f2(box2[[1]]), f2(box3[[1]]), f2(box4[[1]]))
}

#' Network visualization dashboard
#'
#' @param p1 object of class visjs
#' @export
networkVizDashboard = function(p1){
  tour = intro(list(
    list(intro = 'Network Visualization)'),
    list(
      intro = "Use this search box to select and highlight nodes by their name.",
      element = JS("document.querySelector('#searchdiv')"),
      numberPosition = "bottom-left"
    ),
    list(
      intro = "This panel displays important statistics for the network",
      element = JS("document.querySelector('#graphbox')")
    ),
    list(
      intro = "This panel displays the distribution of different centrality measures. Click at the bottom to view the distribution for a different measure.",
      element = JS("document.querySelector('#centrality')")
    )
  ), list(), button = '.navbar li>a', width = 90, height = 30)


  myNavBar <- Navbar2("Network Visualization",
      navList(
        navItem(icon('play'), 'Tour', href='#')
        #,navItem(icon('cog'), 'About', href='#')
      ),
      tags$div(id = 'controls',
        tags$div(class = 'col-md-6 pull-right', style = 'margin-top:8px;', id = "searchdiv",
          tags$select(id = 'search', class = 'form-control')
        )
      )
  )

  p4 = ihist(lapply(list(
    degree = degree(p1$x$graph),
    betweenness = betweenness(p1$x$graph),
    closeness = closeness(p1$x$graph)
  ), unname), height = 250, width = '100%')

  mystyle = "
  .introjs-helperNumberLayer{
    border: none;
    background: steelblue;
    box-shadow: none;
    border-radius: 0;
  }
  .infobox .statistic{font-size: 2em;}
  .infobox span.measure2{font-size: 0.9em;}
  "
  NOTE1 = 'Mouseover to see details. Click to select a node. Click outside the graph to reset selection.'

  k1 <- keen_dash(
    tags$style(mystyle),
    myNavBar,
    Row(
      Panel(c(xs = 12, md = 7), p1, title = 'Network Visualization', notes = NOTE1),
      Column(c(xs = 12, md= 5),
        Row(graph_box(p1$x$graph)),
        Row(Panel(c(xs = 12), p4, title = 'Centrality Distribution', id = 'centrality'))
      )
    ),
    tour,
    tags$script("
      $(document).ready(function(){
       $('[data-toggle=popover]').popover()
       document.querySelector('body div').style['font-size'] = null
      })
    ")
  )
  return(k1)
}

graph_box2 = function(x, div = 'col-xs-3'){
  box1 = list(
    Diameter = list(
      value = round(diameter(x), 2),
      title = '',
      definition = '<p style="text-align:justify;">The diameter of a graph is the length of the longest geodesic.</p>'
    )
  )
  box2 = list(
    Density = list(
      value = round(graph.density(x), 2),
      title = '',
      definition = '<p style="text-align:justify;">density</p>'
    )
  )
  box3 = list(
    `Path Length` = list(
      value = round(average.path.length(x), 2),
      title = '',
      definition = '<p style="text-align:justify;">Path Length</p>'
    )
  )
  box4 = list(
    `Clustering` = list(
      value = round(transitivity(x), 2),
      title = '',
      definition = '<p style="text-align:justify;">Clustering</p>'
    )
  )
  infobox(box1, box2, box3, box4, div = div)
}


#' Network visualization dashboard
#'
#' @param p1 object of class visjs
#' @param p4 object for panel 2
#' @param p5 object for panel 3
#' @export
dtDashboard = function(p1, p4, p5){
  tour = intro(list(
    list(intro = 'Decision Tree'),
    list(
      intro = "Use this search box to select and highlight nodes by their name.",
      element = JS("document.querySelector('#searchdiv')"),
      numberPosition = "bottom-left"
    ),
    list(
      intro = "This panel displays an interactive decision tree",
      element = JS("document.querySelector('#dtree')"),
      numberPosition = "top-right",
      tooltipPosition = "right"
    ),
    list(
      intro = "The confusion matrix helps visualize how the classifier performed across different response classes. You can mouseover the matrix to get more information.",
      element = JS("document.querySelector('#confmat')")
    ),
    list(
      intro = "This panel displays the distribution of different centrality measures. Click at the bottom to view the distribution for a different measure.",
      element = JS("document.querySelector('#centrality')")
    )
  ), list(), button = '.navbar li>a', width = 90, height = 30)

  myNavBar <- Navbar2("Decision Tree",
      navList(
        navItem(icon('play'), 'Tour', href='#')
        #,navItem(icon('cog'), 'About', href='#')
      ),
      tags$div(id = 'controls',
        tags$div(class = 'col-md-6 pull-right', style = 'margin-top:8px;', id = "searchdiv",
          tags$select(id = 'search', class = 'form-control')
        )
      )
  )

  mystyle = "
  .d3-tip{
    font-weight: normal;
    line-height: 1.4em;
    pointer-events: none !important;
  }
  .introjs-helperNumberLayer{
    border: none;
    background: steelblue;
    box-shadow: none;
    border-radius: 0;
  }
  .infobox .statistic{font-size: 2em;}
  .infobox span.measure2{font-size: 0.9em;}
  "
  NOTE1 = 'Mouseover to see details. Click to select a node. Click outside the graph to reset selection.'

  k1 <- keen_dash(
    tags$style(mystyle),
    myNavBar,
    Row(
      Panel(c(xs = 12, md = 7), p1, title = 'Decision Tree', notes = NOTE1, id = 'dtree'),
      Column(c(xs = 12, md= 5),
        #Row(graph_box(p1$x$graph)),
        Row(Panel(c(xs = 12), p4, title = 'Variable Importance', id = 'centrality')),
        Row(Panel(c(xs = 12), p5, title = 'Confusion Matrix', id = 'confmat'))
      )
    ),
    tour,
    tags$script("
      $(document).ready(function(){
       $('[data-toggle=popover]').popover()
       document.querySelector('body div').style['font-size'] = null
      })
    ")
  )
  return(k1)
}
