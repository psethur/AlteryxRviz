## Utility Functions

`%||%` <- function(x, y){
  if (is.null(x)) y else x
}

pack <- function(d){
  apply(d, 1, paste, collapse = ',')
}

getLevel = function(f){
  xx = unique(f$from)
  xx2 = setNames(seq_along(xx), xx)
  unname(xx2[as.character(f$from)])
}

getLabel = function(fit, pretty = FALSE, ..., fn = NULL){
  if (is.null(fn)){
    fn = function(x){sub("^(.*)([<|>])(.*)$", "\\1\\\n\\2\\3", x)}
  }
  fn(labels(fit, pretty = pretty, ...))
}


getProb = function(frame){
  l = (NCOL(frame$yval2) - 2)/2
  prob = frame$yval2[,seq(l + 2, 2*l + 1, 1)]
  pack(prob)
}

getConfidence <- function(frame){
  l = (NCOL(frame$yval2) - 2)/2
  prob = frame$yval2[,seq(l + 2, 2*l + 1, 1)]
  apply(prob, 1, max)
}

getCount = function(frame){
  l = (NCOL(frame$yval2) - 2)/2
  counts = frame$yval2[,seq(2, l + 1, 1)]
  pack(counts)
}

processFrame = function(fit){
  f = fit$frame
  f$label = getLabel(fit)
  f$to <- as.numeric(row.names(f))
  f$from <- f$to %/% 2
  f$level = getLevel(f)
  ## HACK: Ideally, I want to expose this to the end-user
  if (is.numeric(f$yval)){
    f$yval = round(f$yval, 3)
  }
  return(f)
}


getVertexColors = function(vertices, palette){
  l = length(levels(vertices$predicted))
  sapply(1:NROW(vertices), function(i){
    yval = vertices$predicted[i]
    prob = vertices$confidence[i]
    sprintf("rgba(%s, %s)",  paste(col2rgb(palette[yval]), collapse = ","), prob)
  })
}

getVertexLabels <- function(fit){
  f = processFrame(fit)
  sapply(row.names(f), function(i){
    x = f[f$from == i,][1,'label']
    if (is.na(x)){
      if (f[f$to == i, 'var'] == "<leaf>"){
        x = f[f$to == i, 'yval']
        x = attr(fit, 'ylevels')[x] %||% x
      }
    }
    return(x)
  })
}

getVertices <- function(fit, palette = NULL){
  frame = processFrame(fit)
  #if (is.null(palette)){
  #  palette = rainbow_hcl(length(attr(fit, 'ylevels')), l = 50)
  #}
  #parents = unique(frame$from) %>% setNames(seq_along(.), .)
  parents = setNames(seq_along(unique(frame$from)), unique(frame$from))
  vertices = data.frame(
    name = row.names(frame),
    level = unname(parents[as.character(frame$from)]),
    n = frame$n
  )
  if (is.null(frame$yval2)){
    vertices$yval = frame$yval
    vertices$color = palette[cut(frame$yval, 5, labels = F)]
    vertices$title = paste(frame$n, "(", frame$n/frame$n[1], ")")
  } else {
    vertices = transform(vertices,
      predicted = attr(fit, 'ylevels')[frame$yval],
      support = frame$yval2[,'nodeprob'],
      confidence = getConfidence(frame),
      probs = getProb(frame),
      counts = getCount(frame)
    )
    vertices$group = vertices$predicted
    vertices$color = getVertexColors(vertices, palette)
  }
  vertices$label = getVertexLabels(fit)
  return(vertices)
}

getEdges <- function(fit){
  f = processFrame(fit)
  f2 = f[-1, c('from', 'to')]
  f2$weight = f$n[-1]/f$n[1]
  return(f2)
}

#' Render Decision Tree
#'
#' @param fit model object of class rpart
#' @param colpal color palette
#' @param tooltipParams extra parameter to pass to tooltip
#' @import RColorBrewer
#' @export
renderTree = function(fit, colpal = NULL, tooltipParams = NULL){
  if (is.null(tooltipParams)){
    tooltipParams = list(width = '210px', height = '70px', top = '110px',
      left = '20px'
    )
  }
  if (is.null(colpal)){
    #colpal = colorspace::rainbow_hcl(length(attr(fit, 'ylevels')),
    #  c = 120, l = 60
    #)
    if (is.null(fit$frame$yval2)){
      colpal = RColorBrewer::brewer.pal(5, 'Blues')
    } else {
      l = length(attr(fit, 'ylevels'))
      colpal = RColorBrewer::brewer.pal(l, 'Set2')
    }
  }
  edges = getEdges(fit)
  vertices = getVertices(fit, colpal)

  v = vis(edges, vertices = vertices, width = '100%', height = 650) %>%
    size_by(10, shape = 'dot') %>%
    add_layout(layout_as_tree, xmax = 1200, root = 1, flip.y = FALSE) %>%
    update_options(
      tree = TRUE,
      nodes = list(
        font = list(size = 20, background = 'whitesmoke')
      ),
      interaction = list(navigationButtons = TRUE, hover = TRUE),
      edges = list(
        smooth = list(type = 'cubicBezier', forceDirection = 'vertical',
          roundness = 0.9
        ),
        color = list(inherit = 'to')
      ),
      interaction = list(hover = !is.null(fit$frame$yval2)),
      miscopts = list(
        col = colpal, labels = attr(fit, 'ylevels'),
        tooltipParams = tooltipParams
      )
    )
  return(v)
}

#' Interactive Variable Importance Plot
#'
#' @param fit model object of class rpart
#' @param limit number of variables to plot
#' @param ... additional arguments
#'
#' @export
varImpPlot = function(fit, limit = 10, ...){
  d = data.frame(
    x = names(fit$variable.importance),
    y = fit$variable.importance
  )
  d$y = round(d$y/sum(d$y)*100, 1)
  d = head(d, limit)
  margin = list(left = 9*max(nchar(as.character(d$x))))
  p4 = c3(
    data = list(json = d, keys = list(x = 'x', value = list('y')), type = 'bar'),
    axis = list(
      rotated = TRUE,
      x = list(type = "category", tick = list(outer = list(show = FALSE))),
      y = list(label = 'Variable Importance')
    ),
    grid = list(y = list(show = TRUE)),
    tooltip = list(show = FALSE),
    legend = list(show = FALSE),
    width = '100%',
    height = 300
  )
  names(d) = c('y', 'x')
  d2 = list(key = 'A', label = 'A', value = d)
  p4b = horizontalBarChart(d2, margin = margin, height = 300, width = '100%')
  return(p4b)
}

#' Get Confusion Matrix
#'
#' @param mod model object of class rpart
#'
#' @export
getConfMatrix <- function(mod){
  outcome = as.character(attr(mod, 'ylevels')[mod$y])
  pred = predict(mod, type = "class")
  d <- as.matrix(addmargins(table(outcome, pred), c(1, 2)))
  d2 <- as.data.frame(d/rowSums(d)*2)
  d3 <- as.data.frame(d, stringsAsFactors = F)
  d3$c <- d2$Freq
  names(d3)[1:2] = c('y', 'x')
  d3[d3$x == 'Sum' & d3$y == 'Sum', 'c'] <- sum(d3[d3$x != 'Sum' & d3$y != 'Sum' & (d3$x == d3$y),'Freq'])/tail(d3, 1)$Freq
  return(d3)
}

