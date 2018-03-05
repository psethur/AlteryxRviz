#' Plot an interactive horizontal bar chart
#'
#' @param data data to plot
#' @param ... additional arguments to pass as defaults
#' @param width width of the plot div
#' @param height height of the plot div
#'
#' @import htmlwidgets
#'
#' @export
horizontalBarChart <- function(data, ..., width = 400, height = 400) {
  defaults = list(
    margin =  list(left = 65, right = 80, top = 30, bottom = 30),
    initialHeight = height - 5,
    initialWidth = "auto",
    fontSize = 10
  )
  defaults = modifyList(defaults, list(...))
  # forward options using x
  x = list(
    data = data, defaults = defaults
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'horizontalBarChart',
    x,
    width = width,
    height = height,
    package = 'AlteryxRviz'
  )
}

#' Shiny bindings for horizontalBarChart
#'
#' Output and render functions for using horizontalBarChart within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a horizontalBarChart
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name horizontalBarChart-shiny
#'
#' @export
horizontalBarChartOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'horizontalBarChart', width, height, package = 'AlteryxRviz')
}

#' @rdname horizontalBarChart-shiny
#' @export
renderHorizontalBarChart <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, horizontalBarChartOutput, env, quoted = TRUE)
}
