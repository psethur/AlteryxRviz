#' Create a hovercard
#'
#' @param text text to hover on
#' @param details details to display on hover
#' @param width width of the element
#' @param height height of the element
#' @import htmlwidgets
#' @export
hovercard <- function(text, details, width = NULL, height = NULL) {

  # forward options using x
  x = list(
    text = text, details = details
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'hovercard',
    x,
    width = width,
    height = height,
    package = 'AlteryxRviz'
  )
}

hovercard_html <- function(id, style, class, ...){
  htmltools::tags$span(id = id, class = class)
}

#' Widget output function for use in Shiny
#'
#' @param outputId id of output element
#' @param width width of widget div
#' @param height height of widget div
#' @export
hovercardOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'hovercard', width, height, package = 'AlteryxRviz')
}

#' Widget render function for use in Shiny
#'
#' @param expr A quoted of unquoted expression, or a function
#' @param env The desired environment for the function. Defaults to the calling
#'   environment two steps back
#' @param quoted Is the expression quoted?
#' @export
renderHovercard <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, hovercardOutput, env, quoted = TRUE)
}
