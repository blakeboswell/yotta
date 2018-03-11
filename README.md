
# ploom

<!-- [CRAN_Status_Badge]() -->

<!-- [Build Status]() -->

<!-- [AppVeyor Build Status]() -->

<!-- [Coverage Status]() -->

## Overview

A collection of tools for out-of-memory linear model fitting and
inference. Implements `lm` and `glm` analogs using Alan Miller’s AS274
updating QR factorization algorithm. Collects and reports an array of
pertinent fit statistics. Provides flexible and easy to use mechanisms
to stream in data and stream out results during fitting.

> Currently in early development stage.

### tl;dr Features

> forthcoming

## Installation

``` r
# the early development version from GitHub:
# install.packages("devtools")
devtools::install_github("bboswell/ploom")
```

## Usage

The core of `ploom` consists of

  - **`oomlm`** and **`oomglm`** for fitting linear and generalized
    linear models to data
  - **`oomfeeds`** that provide a flexible interface for streaming data
    to and from `oomlm` and `oomglm`

The functions `oomlm` and `oomglm` work as you would expect when fitting
in-memory data.

``` r
w <- oomlm(mpg ~ cyl + disp, data = mtcars)
```

Similar to `biglm`, `ploom` can be updated with new data after being
initially fit.

``` r
# proxy for big data feed
chunks <- purrr::pmap(mtcars, list)

# initial fit
x  <- oomlm(mpg ~ cyl + disp, chunks[[1]])

# iteratively update model with more data
for(chunk in chunks[2:length(chunks)]) {
  x <- update_oomlm(x, data = chunk)
}
```

`ploom` models can also be initialized with a formula only, providing
flexibility for initial updates.

``` r
# no index loop
y <- oomlm(mpg ~ cyl + disp)
for(chunk in chunks) {
  update_oomlm(y, chunk)
}

# or avoiding loops altogether with `reduce`
z <- purrr::reduce(
  chunks, update_oomlm, .init = oomlm(mpg ~ cyl + disp)
  )
```

### `streams`

## Alternatives

> forthcoming

## Acknowledgements

> forthcoming
