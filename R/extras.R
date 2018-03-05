#' Create an icon
#'
#' @param x name of glyphicon
#' @param ... other attributes to add to the span element
#' @export
icon <- function(x, ...){
  tags$span(class = sprintf('glyphicon glyphicon-%s', x), ...)
}

#' Create a panel title
#'
#' @param title title
#' @param note note
#' @param idright id of span element created to the far right
#' @export
panel_title <- function(title, note = "", idright){
  tagList(
    tags$span(title),
    icon('info-sign',
        `data-content` = note,
        `data-toggle` = "popover",
        `data-html` = TRUE,
        style = "cursor:pointer;font-size:16px;"
    ),
    tags$span(id = idright, class='pull-right')
  )
}

#' Enable bootstrap based popover
#'
#' @export
enable_popover <- function(){
  tags$script("
    $(document).ready(function(){
      $('[data-toggle=popover]').popover()
    })
  ")
}


#' Customize dygraph theme for Alteryx Dashboards
#'
#' @param x dygraph object
#' @export
dyAlteryxTheme <- function(x){
  x %>%
    dyAxis('x', axisLabelColor = 'gray', drawGrid = F) %>%
    dyAxis('y', axisLineColor = 'transparent', axisLabelColor = 'gray')
}
