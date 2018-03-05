#' Create an interactive ACF plot
#'
#' @param data data to plot
#' @param hlines horizontal markers to plot
#' @param ydomain range for the y-axis
#' @param xlab label for x-axis
#' @param ylab label for y-axis
#' @param width width of the plot
#' @param height height of the plot
#' @import htmlwidgets
#' @export
iacf <- function(data, hlines, ydomain, xlab = 'Lag', ylab = 'ACF',
    width = NULL, height = NULL) {

  # forward options using x
  x = list(
    data = data, hlines = hlines, ydomain = ydomain, xlab = xlab, ylab = ylab
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'iacf',
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
iacfOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'iacf', width, height, package = 'AlteryxRviz')
}

#' Widget render function for use in Shiny
#'
#' @param expr A quoted of unquoted expression, or a function
#' @param env The desired environment for the function. Defaults to the calling
#'   environment two steps back
#' @param quoted Is the expression quoted?
#' @export
renderIacf <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, iacfOutput, env, quoted = TRUE)
}
