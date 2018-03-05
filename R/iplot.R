#' Generic function for extracting plot data from time series objects.
#'
#' @param x a time series object
#' @export
plotData = function(x){
  UseMethod('plotData')
}

#' Generic function for creating interactive plots for time series objects
#'
#' @param x a time series object
#' @param width width of the plot
#' @param height height of the plot
#' @param ... other arguments for the plot
#' @export
#' @import dygraphs
iplot = function(x, width, height, ...){
  UseMethod('iplot')
}

#' Extract plot data from an object of class ets
#'
#' @param x an object of class ets
#' @import xts forecast
#' @export
plotData.ets = function(x){
  if (!is.null(x$lambda)){
    y <- BoxCox(x$x, x$lambda)
  } else {
    y <- x$x
  }
  if(x$components[3] == "N" & x$components[2] == "N"){
    cbind(observed = y, level = x$states[, 1])
  } else if (x$components[3] == "N") {
    cbind(observed = y, level = x$states[, 1], slope = x$states[, "b"])
  } else if (x$components[2] == "N") {
    cbind(observed = y, level = x$states[, 1], season = x$states[,"s1"])
  } else {
   cbind(observed = y, level = x$states[, 1], slope = x$states[, "b"],
      season = x$states[, "s1"]
    )
  }
}

#' Create interactive plot of an object of class ets
#'
#' @param x an object of class ets
#' @param width width of the plot
#' @param height height of the plot
#' @param labelsDiv div element to display legend of dygraph
#' @param ... other arguments to pass to dygraphs::dygraph
#' @export
iplot.ets <- function(x, width = 500, height = 120, labelsDiv = NULL, ...){
  f <- plotData(x)
  d <- lapply(1:NCOL(f), function(i){
    axcol = function(j){
      if (j == NCOL(f)) 'gray' else 'transparent'
    }
    dygraph(as.xts2(f[,i]), width = width, height = height, group = 'linked') %>%
      dySeries("V1", label = colnames(f)[i]) %>%
      dyAxis('x', drawGrid = F, axisLabelColor = axcol(i)) %>%
      dyAxis('y', axisLineColor = 'transparent', axisLabelColor = 'gray',
        label = colnames(f)[i]
      ) %>%
      dyLegend(labelsDiv = labelsDiv)
  })

  p1 <- tags$html(
    #tags$p(plotNote(x)),
    do.call(tagList, d),
    tags$style('.dygraph-ylabel{opacity: 0.8;margin-right:5px;}'),
    tags$style('body{font-family: "Helvetica"}')
  )
  browsable(p1)
}

#' Extract plot data from an object of class stl
#'
#' @param x an object of class stl
#' @import xts forecast
#' @export
plotData.stl <- function(x){
  sers <- x$time.series
  ncomp <- ncol(sers)
  data <- drop(sers %*% rep(1, ncomp))
  X <- cbind(data, sers)
  colnames(X) <- c("data", colnames(sers))
  return(X)
}

#' Create interactive plot of an object of class stl
#'
#' @inheritParams iplot.ets
#' @export
iplot.stl <- iplot.ets

#' Extract plot data from an object of class forecast
#'
#' @param x an object of class forecast
#' @import xts forecast
#' @export
plotData.forecast <- function(x){
  conc_ts <- function(x1, x2){
    ts(c(x1, x2), start = start(x1), frequency = frequency(x1))
  }
  tsNA <- function(x){
    ts(rep(NA, length(x)), start = start(x), frequency = frequency(x))
  }
  cbind(
    Actual = as.xts2(x$x),
    Fitted = as.xts2(conc_ts(x$fitted, x$mean)),
    lwr = as.xts2(conc_ts(x$fitted, x$lower[,1])),
    upr = as.xts2(conc_ts(x$fitted, x$upper[,1])),
    L =  as.xts2(conc_ts(tsNA(x$fitted), x$lower[,2])),
    U = as.xts2(conc_ts(tsNA(x$fitted), x$upper[,2]))
  )
}

#' Create interactive plot of an object of class forecast
#'
#' @param x an object of class forecast
#' @param width width of the plot
#' @param height height of the plot
#' @param ... other arguments to pass to dygraphs::dygraph
#' @export
#' @examples
#'  library(forecast)
#'  fit <- ets(USAccDeaths)
#'  iplot(forecast(fit, h = 48))
iplot.forecast <- function(x, width = NULL, height = NULL, ...){
  plot_data = plotData(x)
  dygraph(plot_data, width = width, height = height) %>%
    dyAxis('y', axisLineColor = 'transparent', axisLabelColor = 'gray') %>%
    dySeries(
      name = 'Actual',
      label = XMSG(in.targetString_sc = 'Actual'),
      color = '#ABABAB'
    ) %>%
    dySeries(
      name = c(
        'lwr',
        'Fitted',
        'upr'
      ),
      label = XMSG(in.targetString_sc = 'Fitted'),
      color = '#006BA4'
    ) %>%
    dySeries(
      name = 'L',
      label = XMSG(in.targetString_sc = 'Lower'),
      strokeWidth = 2,
      strokePattern = "dashed",
      color = '#5F9ED1'
    ) %>%
    dySeries(
      name = 'U',
      label = XMSG(in.targetString_sc = 'Upper'),
      strokeWidth = 2,
      strokePattern = "dashed",
      color = '#5F9ED1'
    )
}

#' Extract plot data from an object of class acf
#'
#' @param x an object of class acf
#' @export
#' @export
#' @examples
#' library(forecast)
#' x = Acf(wineind, plot = FALSE)
#' plotData(x)
plotData.acf = function(x){
  if (x$type == 'correlation'){
    x$acf = x$acf[-1]
    x$lag = x$lag[-1]
  }
  data = data.frame(
    x = x$lag,
    y1 = round(pmin(0, x$acf), 3),
    y2 = round(pmax(0, x$acf), 3)
  )
  hlines = c(-1, 1)*1.96/sqrt(x$n.used)
  ymin = min(min(x$acf), hlines[1])
  if (ymin < 0){
    ymin = ymin*1.3
  }
  ymax = max(max(x$acf), hlines[2])
  ydomain = list(ymin, ymax)
  list(data = data, hlines = hlines, ydomain = ydomain, type = x$type)
}

#' Create interactive plot of an object of class acf
#'
#' @param x an object of class forecast
#' @param width width of the plot
#' @param height height of the plot
#' @param ... other arguments to pass to dygraphs::dygraph
#' @export
#' @export
iplot.acf = function(
  x,
  width = '100%',
  height = 300,
  in.xLabel_sc = 'Lag',
  in.potentialYLabels_vc = c(
    'ACF',
    'PACF'
  )
){
  x = plotData(x)
  if (x$type == 'correlation'){
    ylab = in.potentialYLabels_vc[1]
  } else {
    ylab = in.potentialYLabels_vc[2]
  }
  iacf(
    data = x$data,
    hlines = x$hlines,
    ydomain = x$ydomain,
    xlab = in.xLabel_sc,
    ylab = ylab,
    width = width,
    height = height
  )
}

#' Create interactive plot of an object of class ts
#'
#' @param x an object of class ts
#' @param width width of the plot
#' @param height height of the plot
#' @param label label to use for the y variable in legend
#' @param ... other arguments to pass to dygraphs::dygraph
#' @export
iplot.ts <- function(x, width = '100%', height = 300, label = "V1", ...){
  x <- as.xts2(x)
  dygraph(x, width = width, height = height) %>%
    dySeries("V1", label = label) %>%
    dyAlteryxTheme()
}

# #' @export
# plotNote = function(x){
#   UseMethod('plotNote')
# }
#
# #' @export
# plotNote.default = function(x){
#   return("")
# }
#
# #' @export
# plotNote.stl = function(x){
#   return("STL Decomposition")
# }
#
# #' @export
# plotNote.ets = function(x){
#   x <- "Decomposition Plot separates time series data into several components. Decomposition method is often used to yield information about time series components i.e. trend, cycle, seasonal, etc.
#
#   - Observed: This is the actual data.
#   - Level: This is the overal baseline without seasonal trends.
#   - Slope: This is the rate of change associated with the Level.
#   - Season: This shows the seasonal trend of the data.
#
#   Not all of the above components will occur each time.
# "
#   return()
# }

# plotData.forecast <- function(x){
#   conc_ts <- function(x1, x2){
#     ts(c(x1, x2), start = start(x1), frequency = frequency(x1))
#   }
#   cbind(
#     Actual = as_xts(x$x),
#     Fitted = as_xts(conc_ts(x$fitted, x$mean)),
#     lwr = as_xts(conc_ts(x$fitted, x$lower[,1])),
#     upr = as_xts(conc_ts(x$fitted, x$upper[,1])),
#     L = as_xts(ts(x$lower[,2], start = start(x$mean), frequency = frequency(x$mean))),
#     U = as_xts(ts(x$upper[,2], start = start(x$mean), frequency = frequency(x$mean)))
#   )
# }

# # Copied from lubridate
# date_decimal <- function (decimal, tz = NULL){
#   year <- trunc(decimal)
#   frac <- decimal - year
#   start <- strptime(paste(year, "01", "01"), "%Y %m %d", tz = 'UTC')
#   seconds <- as.numeric(strptime(paste(year + 1, "01", "01"), "%Y %m %d", tz = 'UTC') -
#     start, units = "secs"
#   )
#   start + seconds * frac
# }
#
# as_xts = function(x){
#   if (xtsible(x)){
#     as.xts(x)
#   } else {
#     ix = index(x)
#     if (ix[1] < 1970){
#       ix = ix + 1970
#     }
#     xts(x, order.by = date_decimal(ix))
#   }
# }
#
# as.xts2 = function(x){
#   if (xtsible(x)){
#     as.xts(x)
#   } else {
#     class(x) = c(get_periodicity(x), class(x))
#     as_xts(x)
#   }
# }
#
# get_periodicity <- function(x){
#   pds <- c("1" = 'annually', "4" = 'quarterly', "12" = 'monthly', "52" = 'weekly',
#            "5" = 'daily', "7" = 'daily', "24" = 'hourly'
#   )
#   unname(pds[as.character(frequency(x))])
# }
#
# as_xts <- function(x){
#   UseMethod('as_xts')
# }
#
# as_xts.daily <- function(x){
#   year = sprintf("%04d", start(x)[1])
#   day = start(x)[2]
#   from = strptime(paste(year, day), format = '%Y %j')
#   xts(x, order.by = seq(from, by = 'day', length = NROW(x)))
# }
# as_xts.weekly <- function(x){
#   year = sprintf("%04d", start(x)[1])
#   week = start(x)[2]
#   from = strptime(paste(year, week, 1), format = '%Y %U %u')
#   xts(x, order.by = seq(from, by = 'week', length = NROW(x)))
# }
#
# as_xts.hourly <- function(x){
#   year = sprintf("%04d", start(x)[1])
#   hour = start(x)[2]
#   from = strptime(paste(year, "01", "01", hour), format = '%Y %m %d %H')
#   xts(x, order.by = seq(from, by = 'hour', length = NROW(x)))
# }

