#' Create a table chart
#'
#' This widget creates a sortable table chart.
#'
#' @param measures measures to plot
#' @param heading table heading
#' @param models model names
#' @param footnote footnote to include
#' @param width width of the plot div
#' @param height of the plot div
#'
#' @import htmlwidgets
#'
#' @export
tablechart <- function(measures, heading = 'Measure',
    models = "", footnote = NULL, width = NULL, height = NULL) {

  if (is.null(footnote)){
    footnote = "This table allows you to compare models using different accuracy measures. Click on a measure to sort by it. Mouseover a bar to get the error value."
  }
  # forward options using x
  x = list(data = list(list(
      measures = measures, heading = heading, models = models, footnote = footnote
  )))

  # create widget
  htmlwidgets::createWidget(
    name = 'tablechart',
    x,
    width = width,
    height = height,
    package = 'AlteryxRviz'
  )
}

add_series <- function(x, measures, heading = 'Measure', models = models,
   footnote = 'Note'){
  x$x$data[[length(x$x$data) + 1]] = list(
    measures = measures, heading = heading, models = models, footnote = footnote
  )
  return(x)
}

# Widget output function for use in Shiny
tablechartOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'tablechart', width, height, package = 'peterpan')
}

# Widget render function for use in Shiny
renderTablechart <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, tablechartOutput, env, quoted = TRUE)
}
