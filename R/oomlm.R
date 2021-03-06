
#' Internal. Initialize Updating Linear Model
#' 
#' @md
#' @param formula A symbolic description of the model to be fitted
#'  of class `formula`.
#' @param weights A one-sided, single term `formula` specifying weights.
#'
#' @keywords internal
init_oomlm <- function(formula, weights = NULL) {
  
  if(!is.null(weights) && !inherits(weights, "formula")) {
    stop("`weights` must be a formula")
  }
  
  object <- list(
    formula      = formula,
    terms        = terms(formula),
    weights      = weights,
    call         = sys.call(-1),
    n            = 0,
    df.residual  = NULL,
    qr           = NULL,
    names        = NULL,
    assign       = NULL
  )
  
  class(object) <- "oomlm"
  object
  
}


#' Out of memory Linear model
#' 
#' Perform memory-efficient linear regression using 
#' the AS274 bounded memory QR factorization algorithm.
#' 
#' @md
#' @param formula A symbolic description of the model to be fitted of class
#'  `formula`.
#' @param weights A one-sided, single term `formula` specifying weights.
#' @param ... Ignored.
#' @details
#'  The provided `formula` must not contain any data-dependent terms to ensure
#'  consistency across calls to `fit()`. Factors are permitted, but the
#'  levels of the factor must be the same across all data chunks. Empty factor
#'  levels are accepted.
#'
#' @return An `oomlm` model is perpetually in an _in-progress_ state. It is up
#'  to the user to know when fitting is complete. Therefore, only basic
#'  model characteristics are provided as values. Statistics are available on 
#'  demand via summary and extractor functions.
#'
#' \item{n}{The number of observations processed.}
#' \item{df.residual}{The residual degrees of freedom.}
#' \item{formula}{The `formula` object specifying the linear model.}
#' \item{terms}{The `terms` object specifying the terms of the linear model.}
#' \item{weights}{A one-sided, single term `formula` specifying weights.}
#' \item{call}{The matched call.}
#' @seealso [oomglm()]
#' @aliases AIC.oomlm coef.oomlm confint.oomlm deviance.oomlm family.oomlm 
#'  formula.oomlm print.oomlm print.summary.oomlm summary.oomlm logLik.oomlm
#'  vcov.oomlm BIC.oomlm
#' @export
#' @name oomlm
#' @examples \donttest{
#' # `oomlm` are defined with a call to `oomlm()` and fit to data
#' # with a call to `fit()`
#' x <- oomlm(mpg ~ cyl + disp)
#' x <- fit(x, mtcars)
#' print(x)
#' 
#' 
#' # `oomlm` models can be fit with more data via subsequent calls
#' # to the `fit()` function
#' chunks <- purrr::pmap(mtcars, list)
#' 
#' y <- oomlm(mpg ~ cyl + disp)
#' 
#' for(chunk in chunks) {
#'   y <- fit(y, chunk)
#' }
#' 
#' tidy(x)
#' 
#' # `oomdata_tbl()` facilitates iterating through data rows in chunks
#' chunks  <- oomdata_tbl(mtcars, chunk_size = 1)
#' 
#' # `fit()` will automatically fit over all chunks in an `oomdata`
#' # object
#' z <- oomlm(mpg ~ cyl + disp)
#' z <- fit(z, data = chunks)
#' summary(z)
#'
#' }
oomlm <- function(formula,
                  weights = NULL, ...) {
  init_oomlm(formula, weights)
}


#' Fit `oomlm` model to additional observations
#' 
#' @md
#' @description
#' Update ploom model with new data.
#' 
#' @param object `oomlm` model to be updated.
#' @param data An optional `oomdata_tbl`, `oomdata_dbi`, `oomdata_con`,
#'   `tibble`, `data.frame`, or `list` of observations to fit.
#' @param ... Ignored.
#' 
#' @return `oomlm` object after fitting to `data`.
#'
#' @method fit oomlm
#' @seealso [oomlm()]
#' @export
#' @name fit.oomlm
fit.oomlm <- function(object, data, ...) {
  
  updater <- function(object, data, ...) {
    
    chunk <- unpack_oomchunk(object, data)
    
    if(is.null(object$assign)) {
      object$assign <- chunk$assign
      object$names  <- colnames(chunk$data)
    }
    
    if(is.null(object$qr)) {
      qr <- new_bounded_qr(chunk$p)
    } else {
      qr <- object$qr
    }
    
    object$qr <- update(qr,
                        chunk$data,
                        chunk$response - chunk$offset,
                        chunk$weights)
    
    if(!is.null(object$sandwich)) {
      object$sandwich$xy <-
        update_sandwich(object$sandwich$xy,
                        chunk$data,
                        chunk$n,
                        chunk$p,
                        chunk$response,
                        chunk$offset,
                        chunk$weights)
    }
    
    object$n            <- object$qr$num_obs
    object$df.residual  <- object$n - chunk$p
    
    object
    
  }
  
  if(inherits(data, what = c("oomdata_tbl", "oomdata_dbi", "oomdata_con"))) {
    
    while(!is.null(chunk <- data())) {
      object <- updater(object, chunk, ...)
    }
    
    object
  
  } else {
    updater(object, data, ...)
  }
  
}


#' @export
#' @method print oomlm
print.oomlm <- function(x,
                        digits = max(3L, getOption("digits") - 3L),
                        ...) {
  
  cat("\nCall:  ",
      paste(deparse(x$call), sep = "\n", collapse = "\n"),
      "\n\n",
      sep = "")
  
  if(!is.null(x$se_type)) {
    cat(paste("Standard error type:", x$se_type), "\n\n")  
  }
  
  beta <- coef(x)
  
  if(length(beta)) {
    cat("Coefficients:\n")
    print.default(
      format(beta, digits = digits),
      print.gap = 2L,
      quote     = FALSE)
  } else {
    cat("No coefficients\n")
  }
  
  cat("\n")
  cat("Observations included: ", x$n, "\n")
  
  invisible(x)
  
}

