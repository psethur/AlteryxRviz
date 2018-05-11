# encode_images = function(nodes){
#   if ('image' %in% names(nodes)){
#     nodes$image = sapply(nodes$image, function(x){
#       if (is.na(x) || grepl('^http', x)){
#         x
#       } else {
#         base64enc::dataURI(
#           file = normalizePath(x),
#           mime = paste0('image/', tools::file_ext(x))
#         )
#       }
#     })
#   }
#   return(nodes)
# }

#' Add coordinates based on an igraph layout
#'
#' @param x object of class visjs
#' @param layout layout function or string
#' @param seed random seed to initialize prior to computing the layout
#' @param xmin minimum value of x to scale the layout to
#' @param xmax maximum value of x to scale the layout to
#' @param ymin minimum value of y to scale the layout to
#' @param ymax maximum value of y to scale the layout to
#' @param ... additional arguments to pass to the layout function
#'
#' @export
add_layout = function(x, layout, seed = 1234,
    xmin = 0, xmax = 1200, ymin = 0, ymax = 800, ...){
  set.seed(seed)
  l = layout(x$x$graph, ...)
  l = layout.norm(l, xmin, xmax, ymin, ymax)
  x$x$coords = setNames(as.data.frame(l), c('x', 'y'))
  #if (length(x$x$options) == 0) x$x$options = list()
  #x$x$options = modifyList(x$x$options, list(
  #  edges = list(smooth = F),
  #  physics = FALSE)
  #)
  update_options(x, edges = list(smooth = F), physics = F)
}

#' Size vertices based on a variable or a function
#'
#' @param x object of class visjs
#' @param f function or variable to use for scaling nodes
#' @param scaling named list of min and max values to use for scaling
#' @param shape string indicating the shape of the node
#' @param ... additional arguments to pass to the function f
#' @export
size_by <- function(x, f, scaling = list(min = 10, max = 30),
    shape = 'dot', ...){
  g = x$x$graph
  if (is.numeric(f)){
    r = update_options(x, nodes = list(size = f, shape = shape))
    return(r)
  }
  if (is.character(f)){
    txt = paste0('V(g)$', f)
    y = eval(parse(text = txt))
    if (is.null(y)){
      f = match.fun(f)
      y = f(g, ...)
    }
  } else {
    f = match.fun(f)
    y = f(g, ...)
  }
  if (is.list(y)){
    y = y$vector
  }

  #if (!is.null(to)){
  #  y = scales::rescale(y, from = range(y), to = to)
  #}
  #V(x$x$graph)$size = y
  V(x$x$graph)$value = y
  #if (length(x$x$options) == 0) x$x$options = list()
  #x$x$options = modifyList(x$x$options, list(
  #  nodes = list(shape = shape)
  #))
  update_options(x, nodes = list(
    shape = shape,
    scaling = list(min = scaling$min, max = scaling$max)
  ))
}

#' Cluster nodes based on a variable or a function
#'
#' @param x object of class visjs
#' @param f function or variable to use for clustering nodes
#' @param ... additional arguments to pass to function f
#' @export
group_by <- function(x, f, ...){
  g = x$x$graph
  if (is.character(f)){
    txt = paste0('V(g)$', f)
    y = eval(parse(text = txt))
    if (is.null(y)){
      f = match.fun(f)
      y = membership(f(g, ...))
    }
  } else {
    f = match.fun(f)
    y = membership(f(g, ...))
  }
  V(x$x$graph)$group = y
  return(x)
}

#' Update options
#'
#' @param x object of class visjs
#' @param ... named options
#' @export
update_options <- function(x, ...){
  if (length(x$x$options) == 0) x$x$options = list()
  x$x$options = modifyList(x$x$options, list(...))
  return(x)
}

as.xts2 = function(x){
  if (xtsible(x)){
    as.xts(x)
  } else {
    class(x) = c(get_periodicity(x), class(x))
    as_xts(x)
  }
}

get_periodicity <- function(x){
  pds <- c("1" = 'annually', "4" = 'quarterly', "12" = 'monthly', "52" = 'weekly',
    "5" = 'weekday', "7" = 'daily', "24" = 'hourly'
  )
  unname(pds[as.character(frequency(x))])
}

get_week_format <- function(){
  f <- getOption('alteryx.week.format', 'US')
  fs <- list(US = '%U', ISO8601 = '%V', UK = '%W')
  fs[[f]]
}

as_xts <- function(x){
  UseMethod('as_xts')
}

as_xts.weekday <- function(x){
  year = sprintf("%04d", start(x)[1])
  day = start(x)[2]
  from = strptime(
    paste(year, '01', day),
    format = paste('%Y', get_week_format(), '%w')
  )
  order.by = seq(from, by = 'day', length = round(NROW(x) * 7/5) + 1)
  v = rep(NA, length(order.by))
  x1 = as.vector(x)
  v[!(format(order.by, '%w') %in% c("6", "0"))][1:length(x1)] <- x1
  x2 = xts(v, order.by = order.by)
}

#as_xts.daily <- function(x){
#  year = sprintf("%04d", start(x)[1])
#  day = start(x)[2]
#  from = strptime(paste(year, '01', day %% 7),
#    format = paste('%Y', get_week_format(), '%w')
#  )
#  xts(x, order.by = seq(from, by = 'day', length = NROW(x)))
#}
as_xts.daily <- function(x){
 setNames(c(x),1:length(c(x)))   
}

as_xts.weekly <- function(x){
  year = sprintf("%04d", start(x)[1])
  week = start(x)[2]
  from = strptime(paste(year, week, 1),
    format = paste('%Y', get_week_format(), '%u')
  )
  xts(x, order.by = seq(from, by = 'week', length = NROW(x)))
}

as_xts.hourly <- function(x){
  year = sprintf("%04d", start(x)[1])
  hour = start(x)[2]
  from = strptime(paste(year, "01", "01", hour), format = '%Y %m %d %H')
  xts(x, order.by = seq(from, by = 'hour', length = NROW(x)))
}

