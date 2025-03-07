#' Perform a stochastic gradient descent generalized matrix factorization
#' (sgdGMF) on cells, based on the expression or mass spectrometry data in a
#' SingleCellExperiment, SummarizedExperiment or QFeatures object.
#' @param x For \code{calculateCVGMF}, a numeric matrix of expression counts
#' or mass spectrometry intensities where rows are features and columns are
#' cells.
#'
#' Alternatively, a \linkS4class{SummarizedExperiment},
#' \linkS4class{SingleCellExperiment} or \link[QFeatures]{QFeatures} object
#' containing such a matrix.
#' @param ncomponents Numeric vector indicating the different number of
#' components used in cross-validation.
#' @param X Sample-level covariate matrix. Defaults to column of ones.
#' @param Z Feature-level covariate matrix. Defaults to column of ones.
#' @param family The distribution family that is used for the estimation of
#' the parameters.
#' @param offset offset matrix with same dimensions as x that is added to the
#' linear predictor. Note that if family = poisson(),
#' this should therefore be on the log-scale.
#' @param weights weight matrix with same dimensions as x that determines the
#' weight of each observation.
#' @param ntop Numeric scalar specifying the number of features with the
#' highest variances to use for dimensionality reduction. Default uses all
#' features.
#' @param subset_row Vector specifying the subset of features to use for
#' dimensionality reduction. This can be a character vector of row names, an
#' integer vector of row indices or a logical vector.
#' @param assay.type Integer scalar or string indicating which assay of
#' \code{x} contains the values of interest.
#' @param scale Logical scalar, should the expression values be standardized?
#' Not recommended for non-Gaussian data.
#' @param BSPARAM A \linkS4class{BiocSingularParam} object specifying which
#' algorithm should be used to perform the PCA.
#' This is used in \code{runPCA} to put all information in the sample latent
#' factors.
#' @param BPPARAM A \linkS4class{BiocParallelParam} object specifying whether
#' the cross-validation should be parallelized. If BPPARAM$workers > 1 and
#' control.cv$parallel and control.cv$nthreads are
#' not specified, parallelization is enabled with nthreads = BPPARAM$workers.
#' @param altexp String or integer scalar specifying an alternative experiment
#' containing the input data.
#' @param dimred String or integer scalar specifying the existing
#' dimensionality reduction results to use.
#' @param n_dimred Integer scalar or vector specifying the dimensions to use
#' if \code{dimred} is specified.
#' @param exprs_values Alias to \code{assay.type}.
#' @param ... For the \code{calculateCVGMF} generic, additional arguments to
#' pass to specific methods.
#' For the SummarizedExperiment and SingleCellExperiment methods, additional
#' arguments to pass to the ANY method. For the QFeatures method, additional
#' arguments to pass to the SingleCellExperiment method.
#'
#' For \code{runCVGMF}, additional arguments to pass to \code{calculateCVGMF}.
#' @param name String specifying the name to be used to store the result in
#' the \code{\link{reducedDims}} of the output.
#' @param transposed Logical scalar, is \code{x} transposed with cells in rows?
#' @param method estimation algorithm from the \code{sgdGMF} package used.
#' See \link{sgdgmf.fit}.
#' @param sampling sub-sampling strategy to use if method = "sgd".
#' See \link{sgdgmf.fit} from the \code{sgdGMF} package.
#' @param control.init control parameters for the initialization, used in the
#' \code{sgdGMF} package. See \link{sgdgmf.init} and \link{set.control.init}.
#' @param control.alg control parameters for the estimation, used in the
#' \code{sgdGMF} package. See \link{sgdgmf.fit} and \link{set.control.alg}.
#' @param control.cv control parameters for the cross-validation, used in the
#' \code{sgdGMF} package. See \link{sgdgmf.cv} and \link{set.control.cv}.
#' @param penalty ridge penalty added for the estimation of the parameters in
#' the \code{sgdGMF} package. see \link{sgdgmf.fit}.
#'
#' @details
#' sgdGMF uses sampling of the data to estimate the parameters, which can
#' alter with different seeds. Also, cross-validation
#' puts a random selection of values to missing. This means that the result
#' will change slightly across different runs.
#' For full reproducibility, users should call \code{\link{set.seed}} prior to
#' running \code{\link{runGMF}} with such algorithms.
#' (Note that this includes \code{BSPARAM=\link{bsparam}()}, which uses
#' approximate algorithms by default.)
#'
#' For feature selection and using alternative Experiments, see
#' \code{\link{runGMF}}.
#'
#'
#' @return
#'
#' For \code{calculateCVGMF}, A table containing the summary statistics of
#' the cross-validation.
#'
#' For \code{runCVGMF}, a SingleCellExperiment object is returned containing
#' this table in the metadata of this object.
#'
#'
#' @name runCVGMF
#' @seealso
#' \code{\link[sgdGMF]{sgdgmf.cv}}, for the underlying calculations.
#'
#' @author Alexandre Segers
#'
#' @examples
#' example_sce <- mockSCE(ncells = 200, ngenes = 100)
#' example_sce <- runCVGMF(example_sce,
#'                          exprs_values="counts",
#'                          family = poisson(),
#'                          ncomponents = c(1:5))
#' head(metadata(example_sce)[["cv_GMF"]])
#' example_sce <- runGMF(example_sce,
#'                       exprs_values="counts",
#'                       family = poisson(),
#'                       ncomponents = 3)
#' reducedDimNames(example_sce)
#' head(reducedDim(example_sce))

NULL

#' @importFrom MatrixGenerics colVars
#' @importFrom DelayedArray DelayedArray
#' @importFrom BiocSingular runPCA bsparam
#' @importFrom BiocParallel SerialParam bpstart bpstop
#' @importFrom scuttle .bpNotSharedOrUp
#' @importFrom sgdGMF sgdgmf.cv
#' @importFrom stats gaussian
.calculate_gmf_cv <- function(x, family = gaussian(), ncomponents = 1:10, ntop=NULL,
                              X = NULL, Z = NULL, offset = NULL, weights = NULL,
                              subset_row=NULL, scale=FALSE, transposed=FALSE,
                              BSPARAM = bsparam(), BPPARAM = SerialParam(),
                              control.init = list(), control.alg = list(),
                              control.cv = list(),
                              penalty = list(), method = "sgd", sampling = "block")
{
  if(length(ncomponents) <= 1) stop("Cross-validation cannot be performed using a single grid search value. Change crossval to FALSE or include a vector of different values.")

  # For DelayedArray's parallelized rowVars/colVars.
  oldbp <- getAutoBPPARAM()
  setAutoBPPARAM(BPPARAM)
  on.exit(setAutoBPPARAM(oldbp))

  if (.bpNotSharedOrUp(BPPARAM)) {
    bpstart(BPPARAM)
    on.exit(bpstop(BPPARAM), add=TRUE)
  }

  if (!transposed) {
    out <- .get_mat_for_reddim(x, subset_row=subset_row, ntop=ntop, scale=scale, get.var=TRUE, family = family)
    if(!is.null(Z)){
        Z <- Z[c(rownames(x)) %in% colnames(out$x),, drop = FALSE]
    }
    if(!is.null(offset)){
        if(all(dim(offset) == dim(x))){
        offset <- t(offset[c(rownames(x)) %in% colnames(out$x),, drop = FALSE])
        } else if(all(dim(offset) == dim(t(x)))){
            offset <- offset[,c(rownames(x)) %in% colnames(out$x), drop = FALSE]
        } else{
            stop("Offset does not have equal dimensions compared to the assay used.")
        }
    }

    if(!is.null(weights)){
        if(all(dim(weights) == dim(x))){
            weights <- t(weights[c(rownames(x)) %in% colnames(out$x),, drop = FALSE])
        } else if(all(dim(weights) == dim(t(x)))){
            weights <- weights[,c(rownames(x)) %in% colnames(out$x), drop = FALSE]
        } else{
            stop("Weights does not have equal dimensions compared to the assay used.")
        }
    }
    x <- out$x
    cv <- out$v
  } else {
    cv <- colVars(DelayedArray(x), useNames = TRUE)
  }

  control.init <- do.call(".set.control.init", control.init)

  if (method == "sgd" & sampling == "block") control.alg <-
      do.call(".set.control.bsgd",
              append(list("dimrow" = nrow(x), "dimcol" = ncol(x)), control.alg))

  if (method == "sgd" & sampling == "coord") control.alg <-
      do.call(".set.control.csgd",
              append(list("dimrow" = nrow(x), "dimcol" = ncol(x)), control.alg))

  if(BPPARAM$workers > 1 & is.null(control.cv$parallel) & is.null(control.cv$nthreads)){
      control.cv$parallel <- TRUE
      control.cv$nthreads <- BPPARAM$workers

  }

  control.cv <- do.call(sgdGMF::set.control.cv, control.cv)
  control.cv$refit <- FALSE


  # if (method == "airwls") control.alg = do.call("set.control.airwls", control.alg)
  # if (method == "newton") control.alg = do.call("set.control.newton", control.alg)
  # if (method == "msgd") control.alg = do.call("set.control.msgd", control.alg)
  # if (method == "csgd") control.alg = do.call("set.control.csgd", control.alg)
  # if (method == "rsgd") control.alg = do.call("set.control.rsgd", control.alg)


  sgd <- sgdGMF::sgdgmf.cv(Y = x,
                           X = X,
                           Z = Z,
                           family = family,
                           ncomp = ncomponents,
                           weights = weights,
                           offset = offset,
                           method = method,
                           sampling = sampling,
                           penalty = penalty,
                           control.init = control.init,
                           control.alg = control.alg,
                           control.cv = control.cv)

  return (sgd$summary.cv)
}

#' @export
#' @rdname runCVGMF
setMethod("calculateCVGMF", "ANY", .calculate_gmf_cv)

#' @export
#' @rdname runCVGMF
#' @importFrom SummarizedExperiment assay
#' @importFrom stats gaussian
setMethod("calculateCVGMF", "SummarizedExperiment", function(x, ..., exprs_values=1, assay.type=exprs_values, family = gaussian())
{
    .checkfamily(assay(x, assay.type), family)
    .calculate_gmf_cv(assay(x, assay.type), family, ...)
})

#' @export
#' @rdname runCVGMF
#' @importFrom stats gaussian
setMethod("calculateCVGMF", "SingleCellExperiment", function(x, ..., exprs_values=1, dimred=NULL, n_dimred=NULL, assay.type=exprs_values, family = gaussian())
{
  mat <- as.matrix(scater:::.get_mat_from_sce(x, assay.type=assay.type, dimred=dimred, n_dimred=n_dimred))
  .checkfamily(mat, family)
  .calculate_gmf_cv(mat, family, transposed=!is.null(dimred), ...)
})

#' @export
#' @rdname runCVGMF
#' @importFrom stats gaussian
setMethod("calculateCVGMF", "QFeatures", function(x, ..., exprs_values = NULL, dimred=NULL, n_dimred=NULL, assay.type=NULL)
{
    if (is.null(assay.type) & is.null(exprs_values)){
        stop("Using a QFeatures class, assay.type should be defined.")
    }
    if (is.null(assay.type)){
        assay.type <- exprs_values
    }
    x <- x[[assay.type]]
    calculateCVGMF(x, ..., dimred = dimred, n_dimred = n_dimred, assay.type = 1)
})





#' @export
#' @rdname runCVGMF
setMethod("runCVGMF", "SummarizedExperiment", function(x, ...)
{
    warning("runCVGMF is only compatible with SingleCellExperiment. Therefore
            the SummarizedExperiment is changed to a SingleCellExperiment.")

    runCVGMF(as(x, "SingleCellExperiment"), ...)
})


#' @export
#' @rdname runCVGMF
#' @importFrom S4Vectors metadata<-
#' @importFrom SingleCellExperiment altExp
setMethod("runCVGMF", "SingleCellExperiment", function(x, ...,
                                                        altexp=NULL,
                                                        name="cv_GMF")
{
    if (!is.null(altexp)) {
        y <- altExp(x, altexp)
    } else {
        y <- x
    }
    S4Vectors::metadata(y)[[name]] <- calculateCVGMF(y, ...)
    y
})


#' @export
#' @rdname runCVGMF
setMethod("runCVGMF", "QFeatures", function(x, ...,
                                          exprs_values = NULL,
                                          assay.type = NULL)
{
    if (is.null(assay.type) & is.null(exprs_values)){
        stop("Using a QFeatures class, assay.type should be defined.")
    }
    if (is.null(assay.type)){
        assay.type <- exprs_values
    }
    x[[assay.type]] <- runCVGMF(x[[assay.type]], ...)
    x
})

