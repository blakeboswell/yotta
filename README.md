
# ploom

[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/ploom)](https://cran.r-project.org/package=ploom)
[![Build
Status](https://api.travis-ci.com/blakeboswell/ploom.svg?branch=develop)](https://api.travis-ci.com/blakeboswell/ploom)
<!-- [AppVeyor Build Status]() --> <!-- [Coverage Status]() -->

## Overview

A collection of tools for **out-of-memory** and **memory efficient**
linear model fitting with support for inference. Implements `lm()` and
`glm()` analogs using Alan Miller’s AS274 updating QR factorization
algorithm.

  - out-of-memory procesing capable of fitting to billion+ observations
  - in-memory runtimes at least as good as `lm()` and `glm()`
  - efficient memory usage ideal for multi-user environments with heavy
    regression loads

> `ploom` is in beta. See [roadmap]() for details.

## Features

  - Linear and Generalized Linear Models
  - Robust Linear and Generalized Linear Models
  - Data streaming functions from Database and file connections as well
    as in-memory chunking of `tibble()` and `data.frame()`

> The beta version of `ploom` has essentially the same features as
> [`biglm`](https://cran.r-project.org/web/packages/biglm/index.html)
> with a slight runtime improvement. More differentiating features are
> currently under development.

## Installation

``` r
# the early development version from GitHub:
# install.packages("devtools")
devtools::install_github("blakeboswell/ploom")
```

## Usage

``` r
library(ploom)

# `oomdata_tbl()` facilitates iterating through data rows in chunks
chunks  <- oomdata_tbl(mtcars, chunk_size = 1)

# linear model
x <- oomlm(mpg ~ cyl + disp, data = chunks)
tidy(x)
```

    ## # A tibble: 3 x 7
    ##   term        estimate std.error statistic  p.value conf.low  conf.high
    ##   <chr>          <dbl>     <dbl>     <dbl>    <dbl>    <dbl>      <dbl>
    ## 1 (Intercept)  34.7       2.55       13.6  4.02e-14  29.5     39.9     
    ## 2 cyl          -1.59      0.712      -2.23 3.37e- 2  -3.04    -0.131   
    ## 3 disp         -0.0206    0.0103     -2.01 5.42e- 2  -0.0416   0.000395

``` r
# generalized linear model fit via IRLS
y <- iter_weight(oomglm(mpg ~ cyl + disp), data = chunks)
tidy(y)
```

    ## # A tibble: 3 x 7
    ##   term        estimate std.error statistic  p.value conf.low  conf.high
    ##   <chr>          <dbl>     <dbl>     <dbl>    <dbl>    <dbl>      <dbl>
    ## 1 (Intercept)  34.7       2.55       13.6  4.02e-14  29.5     39.9     
    ## 2 cyl          -1.59      0.712      -2.23 3.37e- 2  -3.04    -0.131   
    ## 3 disp         -0.0206    0.0103     -2.01 5.42e- 2  -0.0416   0.000395

``` r
con <- RPostgres::dbConnect(drv = RPostgres::Postgres(), dbname = "mtcars")

query <- "
  select mpg, cyl, disp
  from mtcars;
"

chunks <- oomfeed(RPostgres::dbSendQuery(con, query), chunk_size = 4)

x <- oomlm(mpg ~ cyl + disp, data = chunks)
y <- iter_weight(oomglm(mpg ~ cyl + disp), data = chunks)
```

## Alternatives

[`biglm`](https://cran.r-project.org/web/packages/biglm/index.html)
[`speedlm`](https://cran.r-project.org/web/packages/speedlm/index.html)

## Acknowledgements

[`biglm`](https://cran.r-project.org/web/packages/biglm/index.html)
