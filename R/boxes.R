#' Error information
#'
#' @param ... named list of errors to display
#' @export
error_box = function(...){
  x = list(...)
  y = list(
    MAPE = list(
      value = 25,
      title = "Mean Absolute Percent Error",
      definition  = '<p style="text-align:justify">Mean Absolute Percentage Error is the average over the verification sample of the absolute values of the <b>percent</b> differences between forecast and the corresponding observation.</p>'
    ),
    MAE = list(
      value = 45,
      title = "Mean Absolute Error",
      definition  = '<p style="text-align:justify">Mean Absolute Error is the average over the verification sample of the absolute values of the differences between forecast and the corresponding observation. The MAE is a linear score which means that all the individual differences are weighted equally in the average.</p>'
    ),
    MASE = list(
      value = 30,
      title = "Mean Abs Scaled Error",
      definition = '<p style="text-align:justify;"> Mean Absolute Scaled Error is the average over the verification sample of the absolute values of the ratio of the forecast error to the average forecast error of the one-step naive forecast<p>'
    ),
    RMSE = list(
      value = 40,
      title = "Root Mean Square Error",
      definition = '<p style="text-align:justify;"> Root Mean Squared Error is the average over the verification sample of the absolute values of the ratio of the forecast error to the average forecast error of the one-step naive forecast<p>'
    ),
    MPE = list(
      value = 20,
      title =  "Mean Percent Error",
      definition = '<p style="text-align:justify;"> Mean Percent Error is the average over the verification sample of the absolute values of the ratio of the forecast error to the average forecast error of the one-step naive forecast<p>'
    )
  )
  y = lapply(names(x), function(k){
    y[[k]]$value = x[[k]]
    y[[k]]
  })
  return(setNames(y, names(x)))
}

#' AIC information
#'
#' @param ... named list of errors to display
#' @export
aic_box = function(...){
  x = list(...)
  y = list(
    AIC = list(
      value = 1813,
      title = "Akaike Info. Criterion",
      definition = '<p style="text-align:justify">The Akaike information criterion (AIC) is a measure of the relative quality of a statistical model for a given set of data. That is, given a collection of models for the data, AIC estimates the quality of each model, relative to each of the other models. Hence, AIC provides a means for model selection.</p>'
    ),
    AICc = list(
      value = 1819,
      title = "Akaike Info. Criterion Corrected",
      definition = '<p style="text-align:justify">AICc is AIC with a correction for finite sample sizes.</p>'
    ),
    BIC = list(
      value = 1856,
      title = "Bayesian Info. Criterion",
      definition = '<p style="text-align:justify;">Bayesian information criterion (BIC) or Schwarz criterion (also SBC, SBIC) is a criterion for model selection among a finite set of models; the model with the lowest BIC is preferred. It is based, in part, on the likelihood function and it is closely related to the Akaike information criterion (AIC)<p>'
    )
  )
  y = lapply(names(x), function(k){
    y[[k]]$value = x[[k]]
    y[[k]]
  })
  return(setNames(y, names(x)))
}


