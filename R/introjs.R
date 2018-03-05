#' Add a tour
#'
#' This widget creates a tour on a web page.
#'
#' @param steps list of steps for the tour
#' @param options options for the tour
#' @param button boolean indicating if a tour button should be displayed
#' @param width width of the tour button
#' @param height height of the tour button
#' @import htmlwidgets
#' @export
intro <- function(steps, options, button = NULL, width = 30, height = 10) {

  # forward options using x
  x = list(
   steps = steps, options = options, button = button
  )
  x = Filter(Negate(is.null), x)

  # create widget
  htmlwidgets::createWidget(
    name = 'intro',
    x,
    width = width,
    height = height,
    package = 'AlteryxRviz'
  )
}

intro_html = function(id, style, class, ...){
  htmltools::tags$a(id = id, href='#',
    class = paste(class, 'btn btn-success')
  )
}

#' Widget output function for use in Shiny
#'
#' @param outputId id of output element
#' @param width width of widget div
#' @param height height of widget div
#' @export
introOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'intro', width, height, package = 'AlteryxRviz')
}

#' Widget render function for use in Shiny
#'
#' @param expr A quoted of unquoted expression, or a function
#' @param env The desired environment for the function. Defaults to the calling
#'   environment two steps back
#' @param quoted Is the expression quoted?
#' @export
renderIntro <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, introOutput, env, quoted = TRUE)
}
