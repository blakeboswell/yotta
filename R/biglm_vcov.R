
#' vcov implementation for updating linear model
#' (Miller AS274 QR factorization) as implemented
#' in package `biglm`
#' @param np number of parameters in model
#' @param D diagonals of cross products matrix
#' @param rbar the off diagonal portion of the R matrix
#' @keywords internal
rvcov_biglm <- function(np, D, rbar, ok) {
  
  R         <- diag(np)
  R[row(R) > col(R)] <- rbar
  R         <- t(R)
  R         <- sqrt(D) * R
  
  ok        <- D != 0
  R[ok, ok] <- chol2inv(R[ok, ok, drop = FALSE])
  R[!ok, ]  <- NA
  R[, !ok]  <- NA

  R
  
}


#' Hubert/White sandwich vcov implementation for updating linear
#' model (Miller AS274 QR factorization) as implemented 
#' in package `biglm`
#' @param np number of parameters in model
#' @param D diagonals of cross products matrix for sandwich estimator
#' @param rbar the off diagonal portion of the R matrix for sandwich estimator
#' @param R cov matrix for model
#' @param betas model coefficients
#' @param ok boolean indicator of linear independence among coefficients
#' @keywords internal
sandwich_rcov_biglm <- function(np, D, rbar, R, betas, ok) {
  
  rxy  <- diag(np * (np + 1))
  rxy[row(rxy) > col(rxy)] <- rbar
  rxy <- t(rxy)
  rxy <- sqrt(D) * rxy
  M   <- t(rxy) %*% rxy
  
  betas[!ok] <- 0
  bbeta      <- kronecker(diag(np), betas)
  
  ##FIXME: singularities in beta
  Vcenter <- (
    M[1:np, 1:np, drop = FALSE]
    + t(bbeta)
    %*% M[-(1:np), -(1:np), drop = FALSE]
    %*% bbeta
    - t(bbeta)
    %*% M[-(1:np), 1:np, drop = FALSE]
    - M[1:np, -(1:np), drop = FALSE]
    %*% bbeta
  )
  
  V <- matrix(NA, np, np)
  
  V[ok, ok] <- (
    R[ok, ok, drop = FALSE]
    %*% Vcenter[ok, ok, drop = FALSE]
    %*% R[ok, ok, drop = FALSE]
  )
  
  V
  
}