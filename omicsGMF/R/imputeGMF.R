#' Impute missing values based on the results of runGMF.
#'
#' @param x a numeric matrix of expression counts or mass spectrometry
#' intensities containing missing values and with features in the rows and
#' samples in columns.
#'
#' Alternatively, a \linkS4class{SummarizedExperiment},
#' \linkS4class{SingleCellExperiment} or \link[QFeatures]{QFeatures} object
#' containing such a matrix.
#' @param reducedDimName the name of the \code{\link{reducedDim}} slot
#' corresponding to the dimensionality reduction obtained with runGMF when
#' \code{x} is a \linkS4class{SingleCellExperiment} or
#' \link[QFeatures]{QFeatures} object.
#' @param sgdGMF_reducedDims the output obtained by \code{\link{runGMF}} or
#' \code{\link{calculateGMF}}. If \code{x} is a
#' \linkS4class{SingleCellExperiment}, \code{sgdGMF_reducedDims} is taken
#' from \code{\link{reducedDim}(x, reducedDimName)}.
#' @param assay.type Integer scalar or string indicating which assay of
#' \code{x} contains the values of interest.
#' @param exprs_values Alias to \code{assay.type}.
#' @param name New assay name included for the matrix with imputed values.
#' @param ... For the \code{imputeGMF} generic, additional arguments to
#' pass to specific methods.
#'
#' @details
#' Imputation is only possible after running \code{runGMF} using all features.
#' Therefore, \code{subset_row} or \code{ntop} should be set to NULL when
#' performing the matrix factorization.
#'
#' @return
#' For \linkS4class{SummarizedExperiment},
#' \linkS4class{SingleCellExperiment} or \link[QFeatures]{QFeatures}, a similar
#' object now containing an extra assay with the imputed values.
#'
#' For a matrix, a matrix with missing values imputed.
#'
#' @name imputeGMF
#' @seealso
#' \code{\link{runGMF}}, to conveniently obtain the matrix factorization.
#'
#' @author Alexandre Segers
#'
#' @examples
#' example_sce <- mockSCE(ncells = 200, ngenes = 100)
#' example_sce <- logNormCounts(example_sce)
#' assay(example_sce, 'logcounts')[assay(example_sce, 'logcounts') == 0] <- NA
#' example_sce <- runGMF(example_sce,
#'                       exprs_values="logcounts",
#'                       family = gaussian(),
#'                       ncomponents = 3)
#' example_sce <- imputeGMF(example_sce)
NULL

.imputeMissingValues <- function(x, sgdGMF_reducedDims)
{
    if(attr(sgdGMF_reducedDims,"family")$family != "gaussian"){
        stop("Imputation currently only possible for Gaussian family.")
    }

    if(is.null(attr(sgdGMF_reducedDims, "offset"))){
        means <- attr(sgdGMF_reducedDims,'B') %*% t(attr(sgdGMF_reducedDims,'X')) +
            attr(sgdGMF_reducedDims,'Z') %*% t(attr(sgdGMF_reducedDims,'Gamma')) +
            attr(sgdGMF_reducedDims, 'rotation') %*% t(sgdGMF_reducedDims)
    } else{
        means <- attr(sgdGMF_reducedDims,'B') %*% t(attr(sgdGMF_reducedDims,'X')) +
            attr(sgdGMF_reducedDims,'Z') %*% t(attr(sgdGMF_reducedDims,'Gamma')) +
            attr(sgdGMF_reducedDims, 'rotation') %*% t(sgdGMF_reducedDims) +
            attr(sgdGMF_reducedDims,'offset')
    }

    x[is.na(x)] <- means[is.na(x)]
    x
}


#' @export
#' @rdname imputeGMF
setMethod("imputeGMF", "ANY", .imputeMissingValues)




#' @export
#' @rdname imputeGMF
#' @importFrom SummarizedExperiment assay assay<-
setMethod("imputeGMF", "SummarizedExperiment", function(x, sgdGMF_reducedDims,
                                                        exprs_values=1,
                                                        assay.type=exprs_values,
                                                        name = "imputedAssay")
{
  if(is.null(sgdGMF_reducedDims)){
    stop("first run 'runGMF' to obtain estimations for Imputation")
  }
  if(nrow(attr(sgdGMF_reducedDims,'rotation')) != nrow(x)){
      stop("all features should be used when performing 'runGMF' if
           imputation is wanted.")
  }

  assay(x, name) <-  .imputeMissingValues(assay(x, assay.type), sgdGMF_reducedDims)
  x
})

#' @export
#' @rdname imputeGMF
#' @importFrom SummarizedExperiment assay assay<-
setMethod("imputeGMF", "SingleCellExperiment", function(x,
                                                        reducedDimName = "GMF",
                                                        sgdGMF_reducedDims = reducedDim(x, reducedDimName),
                                                        exprs_values=1,
                                                        assay.type=exprs_values,
                                                        name = "imputedAssay")
{
  if(is.null(sgdGMF_reducedDims)){
    stop("first run 'runGMF' to obtain estimations for Imputation")
  }
  if(nrow(attr(sgdGMF_reducedDims, 'rotation')) != nrow(x)){
        stop("all features should be used when performing 'runGMF' if
             imputation is wanted.")
  }

  assay(x, name) <- .imputeMissingValues(assay(x, assay.type), sgdGMF_reducedDims)
  x

})


#' @export
#' @rdname imputeGMF
#' @importFrom SummarizedExperiment assay assay<-
setMethod("imputeGMF", "QFeatures", function(x,
                                             ...,
                                             reducedDimName = "GMF",
                                             exprs_values=NULL,
                                             assay.type=NULL,
                                             name = "imputedAssay")
{
    if (is.null(assay.type) & is.null(exprs_values)){
        stop("Using a QFeatures class, assay.type should be defined.")
    }

    if (is.null(assay.type)){
        assay.type <- exprs_values
    }

    if(is(x[[assay.type]], "SingleCellExperiment")){
        stop("First run runGMF on the appropriate assay.")
    }

    imputedValues <- .imputeMissingValues(assay(x[[assay.type]], 1),
                                          sgdGMF_reducedDims = reducedDim(x[[assay.type]], reducedDimName))
    newAssay <- x[[assay.type]]
    assay(newAssay) <- imputedValues
    x[[name]] <- newAssay
    x


})
