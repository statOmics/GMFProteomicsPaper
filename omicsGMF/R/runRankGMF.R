#' Perform an eigendecomposition for model selection based on a screeplot.
#'
#' @param x For \code{calculateRankGMF}, a numeric matrix of expression counts or
#' mass spectrometry intensities where rows are features and columns are cells.
#' Alternatively, a \linkS4class{SummarizedExperiment} or
#' \linkS4class{SingleCellExperiment} containing such a matrix.
#'
#' For \code{runRankGMF}, a \linkS4class{SummarizedExperiment},
#' \linkS4class{SingleCellExperiment} or \link[QFeatures]{QFeatures} object
#' containing such a matrix.
#' @param maxcomp Scalar indicating the maximal number of eigenvalues to
#' compute.
#' @param X Sample-level covariate matrix. Defaults to column of ones.
#' @param Z Feature-level covariate matrix. Defaults to column of ones.
#' @param family The distribution family that is used for the estimation of
#' the parameters.
#' @param offset offset matrix with same dimensions as x that is added to the
#' linear predictor. Note that if family = poisson(),
#' this should therefore be on the log-scale
#' @param weights weight matrix with same dimensions as x that determines the
#' weight of each observation.
#' @param ntop Numeric scalar specifying the number of features with the
#' highest variances to use for dimensionality reduction.
#' Default uses all features.
#' @param subset_row Vector specifying the subset of features to use for
#' dimensionality reduction.
#' This can be a character vector of row names, an integer vector of row
#' indices or a logical vector.
#' @param assay.type Integer scalar or string indicating which assay of
#' \code{x} contains the values of interest.
#' @param scale Logical scalar, should the expression values be standardized?
#' Not recommended for non-Gaussian data.
#' @param BSPARAM A \linkS4class{BiocSingularParam} object specifying which
#' algorithm should be used to perform the PCA.
#' This is used in \code{runPCA} to put all information in the sample
#' latent factors.
#' @param BPPARAM A \linkS4class{BiocParallelParam} object specifying whether
#' the cross-validation
#' should be parallelized. If BPPARAM$workers > 1 and control.cv$parallel and
#' control.cv$nthreads are
#' not specified, parallelization is enabled with nthreads = BPPARAM$workers.
#' @param altexp String or integer scalar specifying an alternative experiment
#' containing the input data.
#' @param dimred String or integer scalar specifying the existing
#' dimensionality reduction results to use.
#' @param n_dimred Integer scalar or vector specifying the dimensions to use
#' if \code{dimred} is specified.
#' @param exprs_values Alias to \code{assay.type}.
#' @param ... For the \code{calculateRankGMF} generic, additional arguments to
#' pass to specific methods such as \link{sgdgmf.rank}.
#' For the SummarizedExperiment and SingleCellExperiment methods, additional
#' arguments to pass to the ANY method.
#'
#' For \code{runRankGMF}, additional arguments to pass to \code{calculateRankGMF}.
#' @param name String specifying the name to be used to store the result in
#' the \code{\link{metadata}} of the output.
#' @param transposed Logical scalar, is \code{x} transposed with cells in rows?
#' @param method rank selection method, see \link{sgdgmf.rank}.
#' @param normalize if TRUE, standardize the residual matrix for each feature.
#' @details
#' sgdGMF uses sampling of the data to estimate the parameters, which can
#' alter with different seeds. Also, cross-validation
#' puts a random selection of values to missing. This means that the result
#' will change slightly across different runs.
#' For full reproducibility, users should call \code{\link{set.seed}} prior to
#' running \code{runRankGMF} with such algorithms.
#' (Note that this includes \code{BSPARAM=\link{bsparam}()}, which uses
#' approximate algorithms by default.)
#'
#' For feature selection and using alternative Experiments, see
#' \code{\link{runGMF}}.
#'
#' @return
#' A list containing the eigenvalues. If a
#' \linkS4class{SummarizedExperiment} or \linkS4class{SingleCellExperiment} was
#' given as input, this is stored in the metadata of this object.
#'
#' @name runRankGMF
#' @seealso
#' \code{\link[sgdGMF]{sgdgmf.rank}}, for the underlying calculations.
#'
#' @author Alexandre Segers
#'
#' @examples
#' example_sce <- mockSCE(ncells = 200, ngenes = 100)
#' example_sce <- runRankGMF(example_sce,
#'                          exprs_values="counts",
#'                          family = poisson(),
#'                          maxcomp = 10)
#' head(metadata(example_sce)[["rank_GMF"]])
#' plotRank(example_sce)
NULL

#' @importFrom MatrixGenerics colVars
#' @importFrom DelayedArray DelayedArray
#' @importFrom BiocParallel SerialParam bpstart bpstop
#' @importFrom scuttle .bpNotSharedOrUp
#' @importFrom sgdGMF sgdgmf.rank
#' @importFrom stats gaussian
.calculate_gmf_rank <- function(x, family = gaussian(), maxcomp = 100, ntop=NULL,
                              X = NULL, Z = NULL, offset = NULL, weights = NULL,
                              subset_row=NULL, scale=FALSE, transposed=FALSE,
                              BSPARAM = bsparam(), BPPARAM = SerialParam(),
                              method = "oht", normalize = FALSE, ...
                              )
    #TODO: ask Cristian upon default of method = "oht"
{
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



    if(BPPARAM$workers > 1){
        parallel <- TRUE
        nthreads <- BPPARAM$workers

    }


    rank <- sgdGMF::sgdgmf.rank(Y = x,
                             X = X,
                             Z = Z,
                             maxcomp = maxcomp,
                             family = family,
                             weights = weights,
                             offset = offset,
                             method = method,
                             normalize = normalize,
                             ...)

    return (rank)
}

#' @export
#' @rdname runRankGMF
setMethod("calculateRankGMF", "ANY", .calculate_gmf_rank)

#' @export
#' @rdname runRankGMF
#' @importFrom SummarizedExperiment assay
#' @importFrom stats gaussian
setMethod("calculateRankGMF", "SummarizedExperiment", function(x, ..., exprs_values=1, assay.type=exprs_values, family = gaussian())
{
    .checkfamily(assay(x, assay.type), family)
    .calculate_gmf_rank(assay(x, assay.type), family, ...)
})

#' @export
#' @rdname runRankGMF
#' @importFrom stats gaussian
setMethod("calculateRankGMF", "SingleCellExperiment", function(x, ..., exprs_values=1, dimred=NULL, n_dimred=NULL, assay.type=exprs_values, family = gaussian())
{
    mat <- as.matrix(scater:::.get_mat_from_sce(x, assay.type=assay.type, dimred=dimred, n_dimred=n_dimred)) # TODO: check if needed & for dellayarray
    .checkfamily(mat, family)
    .calculate_gmf_rank(mat, family, transposed=!is.null(dimred), ...)
})

#' @export
#' @rdname runRankGMF
#' @importFrom stats gaussian
setMethod("calculateRankGMF", "QFeatures", function(x, ..., exprs_values = NULL, dimred=NULL, n_dimred=NULL, assay.type=NULL, family = gaussian())
{
    if (is.null(assay.type) & is.null(exprs_values)){
        stop("Using a QFeatures class, assay.type should be defined.")
    }
    if (is.null(assay.type)){
        assay.type <- exprs_values
    }
    x <- x[[assay.type]]
    calculateRankGMF(x, ..., dimred = dimred, n_dimred = n_dimred, assay.type = 1, family = family)
})


#' @export
#' @rdname runRankGMF
setMethod("runRankGMF", "SummarizedExperiment", function(x, ...)
{
    warning("runRankGMF is only compatible with SingleCellExperiment.
            Thereforethe SummarizedExperiment is changed to a
            SingleCellExperiment.")

    runRankGMF(as(x, "SingleCellExperiment"), ...)
})


#' @export
#' @rdname runRankGMF
#' @importFrom S4Vectors metadata<-
#' @importFrom SingleCellExperiment altExp
setMethod("runRankGMF", "SingleCellExperiment", function(x, ...,
                                                          altexp = NULL,
                                                          name = "rank_GMF")
{
    if (!is.null(altexp)) {
        y <- altExp(x, altexp)
    } else {
        y <- x
    }
    S4Vectors::metadata(y)[[name]] <- calculateRankGMF(y, ...)
    y
})


#' @export
#' @rdname runRankGMF
setMethod("runRankGMF", "QFeatures", function(x, ...,
                                             exprs_values = NULL,
                                             assay.type = NULL)
{
    if (is.null(assay.type) & is.null(exprs_values)){
        stop("Using a QFeatures class, assay.type should be defined.")
    }
    if (is.null(assay.type)){
        assay.type <- exprs_values
    }
    x[[assay.type]] <- runRankGMF(x[[assay.type]], ...)
    x
})

