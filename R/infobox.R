#' Create an infobox.
#'
#' @param ... items in the infobox
#' @param div div element for the infobox
#' @param width width of the box
#' @param height height of the box
#' @import htmlwidgets
#' @export
infobox <- function(..., div, width = NULL, height = NULL) {

  # forward options using x
  x = list(
    data = list(...), div = div
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'infobox',
    x,
    width = width,
    height = height,
    package = 'AlteryxRviz'
  )
}

infobox_html <- function(id, style, class, ...){
  tags$div(id = id, class = class)
}

#' Widget output function for use in Shiny
#'
#' @param outputId id of output element
#' @param width width of widget div
#' @param height height of widget div
#' @export
infoboxOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'infobox', width, height, package = 'AlteryxRviz')
}

#' Widget render function for use in Shiny
#'
#' @param expr A quoted of unquoted expression, or a function
#' @param env The desired environment for the function. Defaults to the calling
#'   environment two steps back
#' @param quoted Is the expression quoted?
#' @export
renderInfobox <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, infoboxOutput, env, quoted = TRUE)
}
