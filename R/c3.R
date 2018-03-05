#' Create a plot using C3.js
#'
#' @param ... payload for C3 plot
#' @param width width of the plot
#' @param height height of the plot
#' @import htmlwidgets
#' @export
c3 <- function(..., width = NULL, height = NULL) {

  # forward options using x
  x = list(
    ...
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'c3',
    x,
    width = width,
    height = height,
    package = 'AlteryxRviz'
  )
}

#' Widget output function for use in Shiny
#'
#' @param outputId id of output element
#' @param width width of widget div
#' @param height height of widget div
#' @export
c3Output <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'c3', width, height, package = 'AlteryxRviz')
}

#' Widget render function for use in Shiny
#'
#' @param expr A quoted of unquoted expression, or a function
#' @param env The desired environment for the function. Defaults to the calling
#'   environment two steps back
#' @param quoted Is the expression quoted?
#' @export
renderC3 <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, c3Output, env, quoted = TRUE)
}
