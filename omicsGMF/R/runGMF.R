#' Perform a stochastic gradient descent generalized matrix factorization
#' (sgdGMF) on cells or bulk samples, based on the expression or mass
#' spectrometry data in a SingleCellExperiment, SummarizedExperiment or
#' QFeatures object.
#'
#' @param x For \code{calculateGMF}, a numeric matrix of expression counts or
#' mass spectrometry intensities where rows are features and columns are cells.
#'
#' Alternatively, a \linkS4class{SummarizedExperiment},
#' \linkS4class{SingleCellExperiment} or \link[QFeatures]{QFeatures} object
#' containing such a matrix.
#' @param ncomponents Numeric scalar indicating the number of principal
#' components to estimate.
#' @param X Sample-level covariate matrix. Defaults to column of ones.
#' @param Z Feature-level covariate matrix. Defaults to column of ones.
#' @param family The distribution family that is used for the estimation of
#' the parameters.
#' @param offset offset matrix with same dimensions as x that is added to the
#' linear predictor. Note that if family = poisson(), this should therefore be
#' on the log-scale.
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
#' This is used in \code{runPCA} to put all information in the sample latent
#' factors.
#' @param BPPARAM A \linkS4class{BiocParallelParam} object specifying whether
#' the initialization and cross-validation should be parallelized.
#' @param altexp String or integer scalar specifying an alternative experiment
#' containing the input data.
#' @param dimred String or integer scalar specifying the existing
#' dimensionality reduction results to use.
#' @param n_dimred Integer scalar or vector specifying the dimensions to
#' use if \code{dimred} is specified.
#' @param exprs_values Alias to \code{assay.type}.
#' @param ... For the \code{calculateGMF} generic, additional arguments to
#' pass to specific methods.
#' For the SummarizedExperiment and SingleCellExperiment methods, additional
#' arguments to pass to the ANY method. For the QFeatures method, additional
#' arguments to pass to the SingleCellExperiment method.
#'
#' For \code{runGMF}, additional arguments to pass to \code{calculateGMF}.
#' @param name String specifying the name to be used to store the result in
#' the \code{\link{reducedDims}} of the output.
#' @param transposed Logical scalar, is \code{x} transposed with cells in rows?
#' @param crossval if TRUE, performs cross-validation followed by fitting a
#' final model with the optimal number of components.
#' Generally not recommended, as no quality control of the cross-validation
#' is done before the final fit.
#' See \link{calculateCVGMF} for cross-validation.
#' @param method estimation algorithm from the \code{sgdGMF} package used.
#' See \link{sgdgmf.fit}. Defaults to 'sgd' for a stochastic gradient
#' descent optimization.
#' @param sampling sub-sampling strategy to use if method = "sgd". See
#' \link{sgdgmf.fit} from the \code{sgdGMF} package. Defaults to 'block'
#' for a block-wise stochastic gradient descent optimization.
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
#' alter with different seeds.
#' This means that the result will change slightly across different runs.
#' For full reproducibility, users should call \code{\link{set.seed}} prior to
#' running \code{runGMF} with such algorithms.
#' (Note that this includes \code{BSPARAM=\link{bsparam}()}, which uses
#' approximate algorithms by default.)
#'
#' @section Feature selection:
#' This section is adapted from the \code{scater} package manual.
#'
#' This section is relevant if \code{x} is a numeric matrix with features in
#' rows and cells in columns;
#' or if \code{x} is a \linkS4class{SingleCellExperiment} and
#' \code{dimred=NULL}.
#' In the latter, the expression values are obtained from the assay specified
#' by \code{assay.type}.
#'
#' The \code{subset_row} argument specifies the features to use for
#' dimensionality reduction.
#' The aim is to allow users to specify highly variable features to improve
#' the signal/noise ratio,
#' or to specify genes in a pathway of interest to focus on particular
#' aspects of heterogeneity.
#'
#' If \code{subset_row=NULL}, the \code{ntop} features with the largest
#' variances are used instead.
#' We literally compute the variances from the expression values without
#' considering any mean-variance trend, nor considering missing values,
#' so often a more considered choice of genes is possible, e.g., with
#' \pkg{scran} functions.
#' Note that the value of \code{ntop} is ignored if \code{subset_row} is
#' specified.
#'
#' If \code{scale=TRUE}, the expression values for each feature are
#' standardized so that their variance is unity.
#' This will also remove features with standard deviations below 1e-8. This
#' is not recommended when using non-Gaussian family distributions.
#'
#' @section Using reduced dimensions:
#' This section is adapted from the \code{scater} package manual.
#'
#' If \code{x} is a \linkS4class{SingleCellExperiment}, the method can be
#' applied on existing dimensionality reduction results in \code{x} by setting
#' the \code{dimred} argument.
#'
#' The matrix of existing reduced dimensions is taken from
#' \code{\link{reducedDim}(x, dimred)}.
#' By default, all dimensions are used to compute the second set of reduced
#' dimensions.
#' If \code{n_dimred} is also specified, only the first \code{n_dimred}
#' columns are used.
#' Alternatively, \code{n_dimred} can be an integer vector specifying the
#' column indices of the dimensions to use.
#'
#' When \code{dimred} is specified, no additional feature selection or
#' standardization is performed.
#' This means that any settings of \code{ntop}, \code{subset_row} and
#' \code{scale} are ignored.
#'
#' If \code{x} is a numeric matrix, setting \code{transposed=TRUE} will treat
#' the rows as cells and the columns as the variables/diemnsions.
#' This allows users to manually pass in dimensionality reduction results
#' without needing to wrap them in a \linkS4class{SingleCellExperiment}.
#' As such, no feature selection or standardization is performed, i.e.,
#' \code{ntop}, \code{subset_row} and \code{scale} are ignored.
#'
#' @section Using alternative Experiments:
#'
#' This section is adapted from the \code{scater} package manual.
#'
#' This section is relevant if \code{x} is a
#' \linkS4class{SingleCellExperiment} and \code{altexp} is not \code{NULL}.
#' In such cases, the method is run on data from an alternative
#' \linkS4class{SummarizedExperiment} nested within \code{x}.
#' This is useful for performing dimensionality reduction on other features
#' stored in \code{\link{altExp}(x, altexp)}, e.g., antibody tags.
#'
#' Setting \code{altexp} with \code{assay.type} will use the specified assay
#' from the alternative \linkS4class{SummarizedExperiment}.
#' If the alternative is a SingleCellExperiment, setting \code{dimred} will
#' use the specified dimensionality reduction results from the alternative.
#' This option will also interact as expected with \code{n_dimred}.
#'
#' Note that the output is still stored in the \code{\link{reducedDims}} of
#' the output SingleCellExperiment.
#' It is advisable to use a different \code{name} to distinguish this output
#' from the results generated from the main experiment's assay values.
#'
#' @return
#' This section is adapted from the \code{scater} package manual.
#'
#' For \code{calculateGMF}, a numeric matrix of coordinates for each cell
#' (row) in each of \code{ncomponents} PCs (column).
#'
#' For \code{runGMF}, a SingleCellExperiment object is returned containing
#' this matrix in \code{\link{reducedDims}(..., name)}.
#'
#' In both cases, the attributes of the PC coordinate matrix contain the
#' following elements:
#' \itemize{
#' \item \code{"rotation"}, the rotation matrix containing loadings for all
#' features used in the analysis and for each PC.
#' \item \code{"X"}, the known sample-level covariate matrix.
#' \item \code{"Beta"}, the estimated parameters related to the known
#' sample-level covariate matrix.
#' \item \code{"Z"}, the known feature-level covariate matrix.
#' \item \code{"Gamma"}, the estimated parameters related to the known
#' feature-level covariate matrix.
#' \item \code{"family"}, the distribution family used for the estimation of
#' the parameters.
#' \item \code{"trace"}, a trace matrix recording the optimization history of
#' sgdGMF.
#' \item \code{"summary.cv"}, only if cross-validation was performed, a
#' summary table of the cross-validation.
#' \item \code{"offset"}, only if offset is not NULL, a matrix containing the
#' offsets.
#'}
#'
#' @name runGMF
#' @seealso
#' \code{\link[sgdGMF]{sgdgmf.fit}}, for the underlying calculations.
#'
#' \code{\link[omicsGMF]{plotGMF}}, to conveniently visualize the results.
#' \code{\link[omicsGMF]{imputeGMF}}, to conveniently impute missing values.
#' @author Alexandre Segers
#'
#' @examples
#' example_sce <- mockSCE(ncells = 200, ngenes = 100)
#' example_sce <- runCVGMF(example_sce,
#'                          exprs_values="counts",
#'                          family = poisson(),
#'                          ncomponents = c(1:5))
#' example_sce <- runGMF(example_sce,
#'                       exprs_values="counts",
#'                       family = poisson(),
#'                       ncomponents = 3)
#' reducedDimNames(example_sce)
#' head(reducedDim(example_sce))
NULL

#' @importFrom MatrixGenerics colVars
#' @importFrom DelayedArray DelayedArray blockApply getAutoBPPARAM setAutoBPPARAM
#' @importFrom BiocSingular runPCA bsparam
#' @importFrom BiocParallel SerialParam bpstart bpstop
#' @importFrom scuttle .bpNotSharedOrUp
#' @importFrom sgdGMF sgdgmf.fit sgdgmf.cv
#' @importFrom stats gaussian
.calculate_gmf <- function(x, family = gaussian(), ncomponents = 50, ntop=NULL,
                           X = NULL, Z = NULL, offset = NULL, weights = NULL,
                           subset_row=NULL, scale=FALSE, transposed=FALSE,
                           BSPARAM = bsparam(), BPPARAM = SerialParam(),
                           control.init = list(), control.alg = list(),
                           crossval = FALSE, control.cv = list(),
                           penalty = list(), method = "sgd", sampling = "block")
{


    # For DelayedArray's parallelized rowVars/colVars.
    oldbp <- getAutoBPPARAM()
    setAutoBPPARAM(BPPARAM)
    on.exit(setAutoBPPARAM(oldbp))

    if (.bpNotSharedOrUp(BPPARAM)) {
        bpstart(BPPARAM)
        on.exit(bpstop(BPPARAM), add=TRUE)
    }

    if(max(rowMeans(is.na(x))) == 1 | max(colMeans(is.na(x))) == 1){
        stop("A row or column contains only missing values. Please remove this observation.")
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
                stop("Offset does not have equal dimensions as the assay used.")
            }
        }

        if(!is.null(weights)){
            if(all(dim(weights) == dim(x))){
                weights <- t(weights[c(rownames(x)) %in% colnames(out$x),, drop = FALSE])
            } else if(all(dim(weights) == dim(t(x)))){
                weights <- weights[,c(rownames(x)) %in% colnames(out$x), drop = FALSE]
            } else{
                stop("Weights does not have equal dimensions as the assay used.")
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

    # if (method == "airwls") control.alg = do.call("set.control.airwls", control.alg)
    # if (method == "newton") control.alg = do.call("set.control.newton", control.alg)
    # if (method == "msgd") control.alg = do.call("set.control.msgd", control.alg)
    # if (method == "rsgd") control.alg = do.call("set.control.rsgd", control.alg)

    if(crossval){
        control.cv <- do.call(sgdGMF::set.control.cv, control.cv)

        if(length(ncomponents) <= 1) stop("Cross-validation cannot be performed using a single grid search value. Change crossval to FALSE or include a vector of different values.")
        if(control.cv$refit != TRUE) stop("calculateGMF and runGMF can only be ran with refit == TRUE. use calculateCVGMF if you want to return only the cross-validation results, or choose the number of components by yourself.")

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

        # Perform PCA to put all information in U instead of V
        orth_sgd <- BiocSingular::runPCA(sgd$U %*% t(sgd$V), center = FALSE,
                                         rank=sgd$ncomp, BSPARAM=BSPARAM, BPPARAM=BPPARAM)

    } else{


        sgd <- sgdGMF::sgdgmf.fit(Y = x,
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
                                  control.alg = control.alg)

        # Perform PCA to put all information in U instead of V
        orth_sgd <- BiocSingular::runPCA(sgd$U %*% t(sgd$V),
                                         center = FALSE,
                                         rank=ncomponents,
                                         BSPARAM=BSPARAM,
                                         BPPARAM=BPPARAM)

    }



    # Saving the results
    pcs <- orth_sgd$x
    rownames(pcs) <- rownames(x)
    rownames(orth_sgd$rotation) <- colnames(x)
    attr(pcs, "rotation") <- orth_sgd$rotation
    attr(pcs, "X") <- sgd$X
    rownames(attr(pcs, "X")) <- rownames(x)
    attr(pcs, "Z") <- sgd$Z
    rownames(attr(pcs, "Z")) <- colnames(x)
    attr(pcs, "Beta") <- sgd$B
    rownames(attr(pcs, "Beta")) <- colnames(x)
    attr(pcs, "Gamma") <- sgd$A
    rownames(attr(pcs, "Gamma")) <- rownames(x)
    attr(pcs, "family") <- sgd$family
    attr(pcs, "trace") <- sgd$trace
    if(crossval) attr(pcs, "summary.cv") <- sgd$summary.cv
    if(!is.null(offset)) attr(pcs, "offset") <- sgd$offset

    return(pcs)
}

#' @export
#' @rdname runGMF
setMethod("calculateGMF", "ANY", .calculate_gmf)

#' @export
#' @rdname runGMF
#' @importFrom SummarizedExperiment assay
#' @importFrom stats gaussian
setMethod("calculateGMF", "SummarizedExperiment", function(x, ..., exprs_values=1, assay.type=exprs_values, family = gaussian()) {
    .checkfamily(assay(x, assay.type), family)
    .calculate_gmf(assay(x, assay.type), family, ...)
})

#' @export
#' @rdname runGMF
#' @importFrom SummarizedExperiment assay
#' @importFrom stats gaussian
setMethod("calculateGMF", "SingleCellExperiment", function(x, ..., exprs_values=1, dimred=NULL, n_dimred=NULL, assay.type=exprs_values, family = gaussian())
{

    mat <- as.matrix(scater:::.get_mat_from_sce(x, assay.type=assay.type, dimred=dimred, n_dimred=n_dimred)) #TODO: is needed for as.matrix? What with delayarray? What with offset?
    .checkfamily(mat, family)
    .calculate_gmf(mat, family, transposed=!is.null(dimred), ...)
})


#' @export
#' @rdname runGMF
#' @importFrom stats gaussian
setMethod("calculateGMF", "QFeatures", function(x, ..., exprs_values = NULL, dimred=NULL, n_dimred=NULL, assay.type=NULL, family = gaussian())
{
    if (is.null(assay.type) & is.null(exprs_values)){
        stop("Using a QFeatures class, assay.type should be defined.")
    }
    if (is.null(assay.type)){
        assay.type <- exprs_values
    }
    x <- x[[assay.type]]
    calculateGMF(x, ..., dimred = dimred, n_dimred = n_dimred, assay.type = 1, family = family)
})



#' @export
#' @rdname runGMF
setMethod("runGMF", "SummarizedExperiment", function(x, ...)
{
    warning("runGMF is only compatible with SingleCellExperiment. Therefore
            the SummarizedExperiment is changed to a SingleCellExperiment.")

    runGMF(as(x, "SingleCellExperiment"), ...)
})


#' @export
#' @rdname runGMF
#' @importFrom SingleCellExperiment reducedDim<- altExp
setMethod("runGMF", "SingleCellExperiment", function(x, ...,
                                                     altexp=NULL, name = "GMF")
{
    if (!is.null(altexp)) {
        y <- altExp(x, altexp)
    } else {
        y <- x
    }
    reducedDim(y, name) <- calculateGMF(x, ...)
    y

})


#' @export
#' @rdname runGMF
setMethod("runGMF", "QFeatures", function(x, ...,
                                          exprs_values = NULL,
                                          assay.type = NULL)
{
    if (is.null(assay.type) & is.null(exprs_values)){
        stop("Using a QFeatures class, assay.type should be defined.")
    }
    if (is.null(assay.type)){
        assay.type <- exprs_values
    }
    x[[assay.type]] <- runGMF(x[[assay.type]], ...)
    x
})






