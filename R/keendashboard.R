#' Create a dashboard
#'
#' This function creates a dashboard using a framework provided by
#' \url{https://github.com/keen/dashboards}
#'
#' @param ... components of dashboard
#' @export
keen_dash <- function(...){
  html <- tags$div(class = "container-fluid", ...)
  htmltools::htmlDependencies(html) <- importKeen()
  htmltools::browsable(html)
}


#' Create a chart panel
#'
#'
#'
#' @param chart chart object to wrap
#' @param cols grid width of the column. can be a named vector to allow for
#'   different column sizes based on screen size.
#' @param title panel title to be displayed at the top
#' @param notes panel notes to be displayed at the bottom
#' @param id id for panel element
#' @export
Panel <- function(cols, chart, title = "", notes = "",
    id = paste0("panel-", round(runif(1)*10000, 0))){
  Column(cols,
    div(class = "chart-wrapper", id = id,
      div(class = "chart-title", title),
      div(class = "chart-stage", chart),
      div(class = "chart-notes", notes)
    )
  )
}

# Import dependencies required for KeenJS
importKeen <- function(pkg = 'AlteryxRviz'){list(
  htmlDependency(
    name = 'jquery',
    src = system.file('htmlwidgets/lib/jquery', package = pkg),
    version = '2.1.1',
    script = 'dist/jquery.min.js'
  ),
  htmlDependency(
    name = 'bootstrap',
    src = system.file('htmlwidgets/lib/bootstrap', package = pkg),
    version = '3.3.4',
    script = 'js/bootstrap.min.js',
    stylesheet  = 'css/bootstrap_standalone.min.css'
  ),
  htmlDependency(
    name = 'keen',
    src = system.file('htmlwidgets/lib/keen-js', package = pkg),
    version = '1.0.0',
    script = c("dist/keen.min.js"),
    stylesheet = c('dist/css/keen-dashboards.css', 'keen-alteryx.css')
  )
)}

#' Create an item in the navbar
#'
#' @param ... attributes for an a element
#' @export
navItem <- function(...){
  tags$li(a(...))
}

#' Create a navbar at the top of the page
#'
#' @param brand title to display on far left of navbar
#' @param ... other elements in navbar
#' @export
Navbar <- function(brand, ...){
  m <- list(...)
  y <- div(class = "navbar-collapse collapse",
    tags$ul(class = "nav navbar-nav navbar-left",
      do.call('tagList', m)
    )
  )
  x <- make_collapsible(brand, y)

  div(class = "navbar navbar-inverse navbar-fixed-top",
    role = "navigation", x
  )
}

# Create collapsible bars
make_collapsible <- function(brand, y){with(tags,
 div(class = "container-fluid",
    div(class = 'navbar-header',
      button(type = 'button', class='navbar-toggle',
        `data-toggle` = "collapse", `data-target` = ".navbar-collapse",
        span("Toggle Navigation", class = "sr-only"),
        span(class = "icon-bar"),
        span(class = "icon-bar"),
        span(class = "icon-bar")
      ),
      a(brand, class = "navbar-brand", href = "")
    ),
    y
  )
)}


#' Create a column
#'
#' @param width the grid width of the column
#' @param ... elements to include within the column
#' @param offset the number of columns to offset this column
#' @param id id for the column
#'
#' @export
Column <- function(width, ..., offset = NULL,
    id = paste0('column-', round(runif(1)*10000))){
  if (length(width) == 1){
    if (is.null(names(width))) width = c(md = width) else width = width
  } else if (is.null(names(width))){
    names(width) <- c('xs', 'sm', 'md', 'lg')[seq_along(width)]
  }
  if (!is.null(offset)){
    if (length(offset) == 1){
      offset = c(md = offset)
    } else if (is.null(names(offset))){
      names(offset) <- c('xs', 'sm', 'md', 'lg')[seq_along(offset)]
    }
  }
  col_class = paste('col', names(width), width, sep = '-')
  if (!is.null(offset)){
    off_class = paste0('col-', names(offset), '-offset-', offset)
    col_class = c(col_class, off_class)
  }
  div(class = paste(col_class, collapse = " "), id = id, ...)
}

#' Create a row
#'
#' @param ... elements to include within a row
#' @export
Row <- function(...){
  div(class = "row", ...)
}

#' List items for navbar
#'
#' @param ... list items
#' @export
navList = function(...){
  m = list(...)
  tags$ul(class = "nav navbar-nav navbar-left", do.call('tagList', m))
}

#' Create a navbar at the top of the page
#'
#' @param brand title to display on far left of navbar
#' @param ... other elements in navbar
#' @export
Navbar2 = function(brand, ...){
  m <- list(...)
  y <- div(class = "navbar-collapse collapse", m)
  x <- make_collapsible(brand, y)

  div(class = "navbar navbar-inverse navbar-fixed-top",
      role = "navigation", x
  )
}


