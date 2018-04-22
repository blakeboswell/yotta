
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
devtools::install_github("blakeboswell/ploom")
```

## Usage

### Model Initializing and Updating

#### Linear

The `ploom` linear model, `oomlm`, is similar to base `lm` for fitting
in-memory data.

``` r
x <- oomlm(mpg ~ cyl + disp, data = mtcars)
```

Models are initalized with a call to `oomlm` and updated with `update`.
The intended pattern is to initialize models without referencing data,
then call `update` on each data chunk.

``` r
# proxy for big data feed 
chunks  <- purrr::pmap(mtcars, list)

# initialize the model
x <- oomlm(mpg ~ cyl + disp)

# iteratively update model with data chunks
for(chunk in chunks) {
  x <- update(x, chunk)
}
```

We can avoid loops with functional patterns like `reduce`.

``` r
x <- purrr::reduce(chunks, update, .init = oomlm(mpg ~ cyl + disp))
```

#### Generalized Linear

The `ploom` generalized linear model, `oomglm`, breaks up the IWLS
fitting process into three process: model initialization, (iterative)
data updates, and iterative reweights.

Consider the in memory case with only a single call to `update`

``` r
# initialize the model
x <- oomglm(mpg ~ cyl + disp)

# re-weight 8 times or until convergence
x <- reweight(x, mtcars, num_iter = 8)
```

For the out-of-memory case, or iterative calls `updates`, use the
`oomfeed` object:

``` r
# proxy for big data feed
chunks  <- purrr::pmap(mtcars, list)

# initialize the model
x <- oomglm(mpg ~ cyl + disp)

# iteratively reweight model over iterative calls to update
x <- reweight(x, oomfeed(mtcars, chunksize = 10), num_iter = 8)
```

### Using Feeds for a Variety of OOM Data Formats

## Alternatives

> forthcoming

## Acknowledgements

> forthcoming
