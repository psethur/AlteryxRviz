#' Plot an Interactive Confusion Matrix
#'
#' @param data confusion matrix data
#' @param ... additional arguments to pass
#' @param width width of the plot div
#' @param height height of the plot div
#'
#' @import htmlwidgets
#'
#' @export
iConfusionMatrix <- function(data, ..., width = 400, height = 400) {
  defaults = list(
    margin =  list(left = 65, right = 80, top = 30, bottom = 30),
    initialHeight = height - 50,
    initialWidth = width - 50,
    fontSize = 10
  )
  # forward options using x
  x = list(
    data = data, defaults = defaults
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'iConfusionMatrix',
    x,
    width = width,
    height = height,
    package = 'AlteryxRviz'
  )
}

#' Shiny bindings for iConfusionMatrix
#'
#' Output and render functions for using iConfusionMatrix within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a iConfusionMatrix
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name iConfusionMatrix-shiny
#'
#' @export
iConfusionMatrixOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'iConfusionMatrix', width, height, package = 'AlteryxRviz')
}

#' @rdname iConfusionMatrix-shiny
#' @export
renderIConfusionMatrix <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, iConfusionMatrixOutput, env, quoted = TRUE)
}
