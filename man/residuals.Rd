% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/residuals.R
\name{residuals}
\alias{residuals}
\alias{residuals.oomlm}
\alias{residuals.oomglm}
\title{Calculate residuals for \code{oomlm} and \code{oomglm} models}
\usage{
\method{residuals}{oomlm}(object, data = NULL, as_function = FALSE,
  ...)

\method{residuals}{oomglm}(object, data = NULL, type = c("deviance",
  "pearson", "response", "working"), as_function = FALSE, ...)
}
\arguments{
\item{object}{An object inheriting from class \code{oomlm}}

\item{data}{Observations for residual calculation.}

\item{as_function}{If \code{TRUE}, a function requiring only \code{data} is
returned for subsequent residual calculations.}

\item{...}{Ignored.}

\item{type}{Residual calculation method for \code{oomglm} models.}
}
\description{
Returns the difference between actual and predicted values.
Since \code{oomlm} models do not store data while fitting, \code{data}
must be supplied to calculate residuals.
}
\seealso{
\code{\link[=oomlm]{oomlm()}}, \code{\link[=oomglm]{oomglm()}}
}
