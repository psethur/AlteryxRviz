#' Visualize using visjs
#'
#' @param x object to create network plot from
#' @param options named list of options
#' @param ... additional arguments
#' @param width width of the plot
#' @param height height of the plot
#' @param elementId id of the widget
#'
#' @import htmlwidgets
#' @export
vis <- function(x, options = c(), ..., width = NULL, height = NULL, elementId = NULL){
  UseMethod('vis')
}

#' Create a network plot from a data frame
#'
#' @param x data frame of edges
#' @param options named list of options
#' @param directed boolean indicating if the graph is directed
#' @param vertices optional data frame of vertices
#' @param type indicating nature of edge data frame - edgelist of adj. matrix.
#' @param width width of the plot
#' @param height height of the plot
#' @param elementId id of the widget
#' @param ... additional arguments
#' @export
#' @import igraph
vis.data.frame <- function(x, options = c(), directed = FALSE, vertices = NULL,
    type = 'edgelist', width = NULL, height = NULL, elementId = NULL, ...){
  if (type == 'edgelist'){
    g = graph.data.frame(d = x, directed = directed, vertices = vertices)
  } else {
    g = graph.adjacency(as.matrix(x), mode = 'undirected', diag = F,
      weighted = 'value'
    )
  }
  vis(g, options = options, width = width, height = height)
}

#' Create network plot from an igraph object
#'
#' @param x object of class igraph to create network plot from
#' @param options named list of options
#' @param ... additional arguments
#' @param width width of the plot
#' @param height height of the plot
#' @param elementId id of the widget
#' @export
vis.igraph <- function(x, options = c(), ..., width = NULL, height = NULL,
    elementId = NULL){
  x = list(
    graph = x,
    options = options
  )
  htmlwidgets::createWidget(
    name = 'vis',
    x,
    width = width,
    height = height,
    elementId = elementId,
    package = 'AlteryxRviz',
    preRenderHook = function(x){
      if (is.directed(x$x$graph)){
        if (length(x$x$options) == 0) x$x$options = list()
        x$x$options = modifyList(x$x$options,
          list(edges = list(arrows = list(to = list(enabled = TRUE))))
        )
      }
      ne = get.data.frame(x$x$graph, what = 'both')
      if (is.null(ne$vertices$name)){
        #ne$vertices$name = unique(
        #  unlist(ne$edges[,c('from', 'to')],
        #    use.names = F
        #  )
        #)
        #ne$vertices$name = sort(ne$vertices$name)
        ne$vertices$name = 1:NROW(ne$vertices)
      }
      x$x$nodes = ne$vertices
      x$x$nodes$id = x$x$nodes$name
      x$x$edges = ne$edges
      if (!is.null(x$x$coords)){
        l = x$x$coords
        #l$x = scales::rescale(l$x, from = range(l$x), to = c(0, 1200))
        #l$y = scales::rescale(l$y, from = range(l$y), to = c(0, 800))
        x$x$nodes = cbind(x$x$nodes, l)
      }
      if (!('label' %in% names(x$x$nodes)) && isTRUE(x$x$options$showLabels)){
        x$x$nodes$label = x$x$nodes$id
        x$x$options$showLabels = NULL
      }
      isTree = !(is.null(x$x$options$tree)) && x$x$options$tree
      if (is.null(x$x$nodes$title) && !(isTree)){
        x$x$nodes$title = paste(x$x$nodes$name,
          "<br/>Betweenness: ", round(betweenness(x$x$graph), 1),
          "<br/>Degree: ", degree(x$x$graph)
        )
      }
      #x$x$nodes = encode_images(x$x$nodes)
      x$x$graph = NULL
      x
    }
  )
}

visPlot = function(x, ...){
  UseMethod('visPlot')
}

visPlot.igraph = function(x, ...){
  xd = get.data.frame(x, what = 'both')
  if (NCOL(xd$vertices) == 0){
    id = unique(unlist(xd$edges, use.names = F))
    nodes = data.frame(id = id, label = paste("Node", id))
  } else {
    nodes = xd$vertices
    nodes$id = nodes$name
    nodes$label = nodes$name
  }
  vis(nodes, xd$edges, ...)
}

#' Widget output function for use in Shiny
#'
#' @param outputId id of output element
#' @param width width of widget div
#' @param height height of widget div
#' @export
visOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'vis', width, height, package = 'visjs')
}

#' Widget render function for use in Shiny
#'
#' @param expr A quoted of unquoted expression, or a function
#' @param env The desired environment for the function. Defaults to the calling
#'   environment two steps back
#' @param quoted Is the expression quoted?
#' @export
renderVis <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, visOutput, env, quoted = TRUE)
}
