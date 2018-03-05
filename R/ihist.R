#' Create an interactive histogram
#'
#' @param data list of vectors
#' @param ... extra arguments
#' @param width width of the histogram
#' @param height height of the histogram
#'
#' @import htmlwidgets
#'
#' @export
ihist <- function(data, ..., width = NULL, height = NULL) {

  # forward options using x
  x = list(
    data = data,
    options = list(...)
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'ihist',
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
ihistOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'ihist', width, height, package = 'AlteryxRviz')
}

#' Widget render function for use in Shiny
#'
#' @param expr A quoted of unquoted expression, or a function
#' @param env The desired environment for the function. Defaults to the calling
#'   environment two steps back
#' @param quoted Is the expression quoted?
#' @export
renderIhist <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, ihistOutput, env, quoted = TRUE)
}
