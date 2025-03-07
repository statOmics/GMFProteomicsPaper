.checkfamily <- function(mat, family){
    if (!all(mat == floor(mat)) & family$family %in% c("poisson", "nb", "negbin")){
        warning("Family is poisson or negative binomial, while assay is not full of integers. Consider changing the assay used or changing the family to gaussian()")
    }
    # if (all(mat == floor(mat)) & family$family == "gaussian"){
    #     warning("Family is gaussian, while assay is full of integers. Consider using poisson() or other families.")
    # }
}

# Set the control parameters of the initialization to the default for omics data.
.set.control.init = function (
        method = c("ols", "glm", "random", "values"),
        type = c("link", "deviance", "pearson", "working"),
        values = list(),
        niter = 5,
        normalize = TRUE,
        verbose = FALSE,
        parallel = FALSE,
        nthreads = 1
) {
    ctr = list()
    ctr$method = match.arg(method)
    ctr$type = match.arg(type)
    ctr$values = list()
    ctr$niter = 5
    ctr$normalize = TRUE
    ctr$verbose = FALSE
    ctr$parallel = FALSE
    ctr$nthreads = 1

    message = function (var)
        warning(paste0("Init. control: '", var,"' was set to default value."),
                call. = FALSE, immediate. = TRUE, domain = NULL)

    if (is.numeric(niter) && niter > 0) ctr$niter = floor(niter) else message("niter")
    if (is.logical(normalize)) ctr$normalize = normalize else message("normalize")
    if (is.logical(verbose)) ctr$verbose = verbose else message("verbose")
    if (is.logical(parallel)) ctr$parallel = parallel else message("parallel")
    if (is.numeric(nthreads) && nthreads > 0) ctr$nthreads = floor(nthreads) else message("nthreads")

    if (is.list(values)) {
        if (length(values) > 0) {
            if (all(c("B", "A", "U", "V") %in% names(values))) {
                if (is.numeric(values$B) && is.matrix(values$B)) ctr$values$B = values$B
                if (is.numeric(values$A) && is.matrix(values$A)) ctr$values$A = values$A
                if (is.numeric(values$U) && is.matrix(values$U)) ctr$values$U = values$U
                if (is.numeric(values$V) && is.matrix(values$V)) ctr$values$V = values$V
            } else {
                values = list()
            }
        }
    }

    return (ctr)
}




# Set the control parameters of the block-wise subsampling to the default for omics data.
.set.control.bsgd = function (
        dimrow,
        dimcol,
        normalize = TRUE,
        maxiter = max(round(dimrow*5 / min(dimrow, max(round(dimrow/10000,0), 100)),0), 10000), # Default, see every data point 5 times, or at least 1000 iterations
        eps = 1e-08,
        nafill = 1,
        tol = 0.001, #Tolerance default 0.001 for 250 iterations
        size = c(min(dimrow, max(round(dimrow/10000,0), 100)),
                 min(dimcol,max(round(dimcol/5,0), 100))),
        burn = 1,
        rate0 = 0.01,
        decay = 0.01,
        damping = 1e-03,
        rate1 = 0.1,
        rate2 = 0.01,
        verbose = FALSE,
        frequency = 250,
        progress = FALSE
) {

    # Set the default control parameters
    ctr = list()
    ctr$normalize = TRUE
    ctr$maxiter = max(round(dimrow*5 / min(dimrow, max(round(dimrow/10000,0), 100)),0), 10000)
    ctr$eps = 1e-08
    ctr$nafill = 1
    ctr$tol = 0.001
    ctr$size = c(min(dimrow, max(round(dimrow/10000,0), 100)),
                 min(dimcol,max(round(dimcol/5,0), 100)))
    ctr$burn = 1
    ctr$rate0 = 0.01
    ctr$decay = 0.01
    ctr$damping = 1e-03
    ctr$rate1 = 0.1
    ctr$rate2 = 0.01
    ctr$verbose = FALSE
    ctr$frequency = 250
    ctr$progress = FALSE

    message = function (var)
        warning(paste0("B-SGD control: '", var,"' was set to default value."),
                call. = FALSE, immediate. = TRUE, domain = NULL)

    # Standard safety checks
    if (is.logical(normalize)) ctr$normalize = normalize else message("normalize")
    if (is.numeric(maxiter) && maxiter >= 1) ctr$maxiter = floor(maxiter) else message("maxiter")
    if (is.numeric(eps) && eps > 0) ctr$eps = eps else message("eps")
    if (is.numeric(nafill) && nafill >= 1) ctr$nafill = floor(nafill) else message("nafill")
    if (is.numeric(tol) && tol > 0) ctr$tol = tol else message("tol")
    if (is.numeric(size) & all(size >= 1)) ctr$size = floor(size[1:2]) else message("size")
    if (is.numeric(burn) && burn > 0 && burn <= 1) ctr$burn = burn else message("burn")
    if (is.numeric(rate0) && rate0 > 0) ctr$rate0 = rate0 else message("rate0")
    if (is.numeric(decay) && decay > 0) ctr$decay = decay else message("decay")
    if (is.numeric(damping) && damping > 0) ctr$damping = damping else message("damping")
    if (is.numeric(rate1) && rate1 > 0) ctr$rate1 = rate1 else message("rate1")
    if (is.numeric(rate2) && rate2 > 0) ctr$rate2 = rate2 else message("rate2")
    if (is.logical(verbose)) ctr$verbose = verbose else message("verbose")
    if (is.numeric(frequency) && frequency >= 1) ctr$frequency = floor(frequency) else message("frequency")
    if (is.logical(progress)) ctr$progress = progress else message("progress")

    # Additional consistency checks
    if (ctr$nafill > ctr$maxiter) {ctr$nafill = ctr$maxiter; message("nafill")}
    if (ctr$eps > 1e-01) {ctr$eps = 1e-01; message("eps")}
    if (ctr$rate1 > 1 - 1e-08) {ctr$rate1 = 1 - 1e-08; message("rate1")}
    if (ctr$rate2 > 1 - 1e-08) {ctr$rate2 = 1 - 1e-08; message("rate2")}
    if (ctr$frequency > ctr$maxiter) {ctr$frequency = ctr$maxiter; message("frequency")}

    # Return the check control parameters
    return (ctr)
}



# Set the control parameters of the coordinate subsampling to the default for omics data.
.set.control.csgd = function (
        dimrow,
        dimcol,
        normalize = TRUE,
        maxiter = max(1000, dimrow*dimcol/(min(dimrow, max(round(dimrow/10000,0), 100))*min(dimcol,max(round(dimcol/5,0), 100)))), # Default, see every data point 5 times, or at least 1000 iterations
        eps = 1e-08,
        nafill = 1,
        tol = 0.001, #Tolerance default 0.001 for 250 iterations
        size = c(min(dimrow, max(round(dimrow/10000,0), 100)),
                 min(dimcol,max(round(dimcol/5,0), 100))),
        burn = 1,
        rate0 = 0.01,
        decay = 0.01,
        damping = 1e-03,
        rate1 = 0.1,
        rate2 = 0.01,
        verbose = FALSE,
        frequency = 250,
        progress = FALSE
) {

    # Set the default control parameters
    ctr = list()
    ctr$normalize = TRUE
    ctr$maxiter = max(1000, dimrow*dimcol/(min(dimrow, max(round(dimrow/10000,0), 100))*min(dimcol,max(round(dimcol/5,0), 100))))
    ctr$eps = 1e-08
    ctr$nafill = 1
    ctr$tol = 0.001
    ctr$size = c(min(dimrow, max(round(dimrow/10000,0), 100)),
                 min(dimcol,max(round(dimcol/5,0), 100)))
    ctr$burn = 1
    ctr$rate0 = 0.01
    ctr$decay = 0.01
    ctr$damping = 1e-03
    ctr$rate1 = 0.1
    ctr$rate2 = 0.01
    ctr$verbose = FALSE
    ctr$frequency = 250
    ctr$progress = FALSE

    message = function (var)
        warning(paste0("C-SGD control: '", var,"' was set to default value."),
                call. = FALSE, immediate. = TRUE, domain = NULL)

    # Standard safety checks
    if (is.logical(normalize)) ctr$normalize = normalize else message("normalize")
    if (is.numeric(maxiter) && maxiter >= 1) ctr$maxiter = floor(maxiter) else message("maxiter")
    if (is.numeric(eps) && eps > 0) ctr$eps = eps else message("eps")
    if (is.numeric(nafill) && nafill >= 1) ctr$nafill = floor(nafill) else message("nafill")
    if (is.numeric(tol) && tol > 0) ctr$tol = tol else message("tol")
    if (is.numeric(size) & all(size >= 1)) ctr$size = floor(size[1:2]) else message("size")
    if (is.numeric(burn) && burn > 0 && burn <= 1) ctr$burn = burn else message("burn")
    if (is.numeric(rate0) && rate0 > 0) ctr$rate0 = rate0 else message("rate0")
    if (is.numeric(decay) && decay > 0) ctr$decay = decay else message("decay")
    if (is.numeric(damping) && damping > 0) ctr$damping = damping else message("damping")
    if (is.numeric(rate1) && rate1 > 0) ctr$rate1 = rate1 else message("rate1")
    if (is.numeric(rate2) && rate2 > 0) ctr$rate2 = rate2 else message("rate2")
    if (is.logical(verbose)) ctr$verbose = verbose else message("verbose")
    if (is.numeric(frequency) && frequency >= 1) ctr$frequency = floor(frequency) else message("frequency")
    if (is.logical(progress)) ctr$progress = progress else message("progress")

    # Additional consistency checks
    if (ctr$nafill > ctr$maxiter) {ctr$nafill = ctr$maxiter; message("nafill")}
    if (ctr$eps > 1e-01) {ctr$eps = 1e-01; message("eps")}
    if (ctr$rate1 > 1 - 1e-08) {ctr$rate1 = 1 - 1e-08; message("rate1")}
    if (ctr$rate2 > 1 - 1e-08) {ctr$rate2 = 1 - 1e-08; message("rate2")}
    if (ctr$frequency > ctr$maxiter) {ctr$frequency = ctr$maxiter; message("frequency")}

    # Return the check control parameters
    return (ctr)
}


# This code is copied from the scater package.
#' @importFrom SummarizedExperiment assay
#' @importFrom SingleCellExperiment reducedDim
.get_mat_from_sce <- function(x, exprs_values, dimred, n_dimred, assay.type=exprs_values) {
    if (!is.null(dimred)) {
        mat <- reducedDim(x, dimred)
        if (!is.null(n_dimred)) {
            if (length(n_dimred)==1L) {
                n_dimred <- seq_len(n_dimred)
            }
            mat <- mat[,n_dimred,drop=FALSE]
        }
        mat
    } else {
        assay(x, assay.type)
    }
}

# This code is adapted from the scater package.
#' @importFrom utils head
#' @importFrom Matrix t
#' @importFrom DelayedArray DelayedArray
#' @importFrom MatrixGenerics rowVars
#' @importFrom beachmat realizeFileBackedMatrix
#' @importFrom scuttle logNormCounts
.get_mat_for_reddim <- function(x, subset_row, ntop, scale, get.var=FALSE, family)
    # Picking the 'ntop' most highly variable features or just using a pre-specified set of features.
    # Also removing zero-variance columns and scaling the variance of each column.
    # Finally, transposing for downstream use (cells are now rows).
{

    use.var <- (is.null(subset_row) || scale || get.var) # TODO: adapt this line or the lines for rv calculation when scale ==
    if (use.var) {
        if(family$family != "gaussian"){
            x_transformed <- scuttle::normalizeCounts(x)
            rv <- MatrixGenerics::rowVars(DelayedArray(x_transformed), useNames = TRUE, na.rm = TRUE)
        } else{
            rv <- MatrixGenerics::rowVars(DelayedArray(x), useNames = TRUE, na.rm = TRUE)

        }
    }

    # If ntop not NULL, use only top variable genes.
    if(!is.null(ntop)){

        if (is.null(subset_row)) {
            o <- order(rv, decreasing = TRUE)
            subset_row <- head(o, ntop)
        } else if (is.character(subset_row)) {
            subset_row <- scater:::.subset2index(subset_row, x, byrow=TRUE)
        }

        x <- x[subset_row,, drop = FALSE]
        if (use.var) {
            rv <- rv[subset_row]
        }

    } else if(!is.null(subset_row)){
        if (use.var) {
            rv <- rv[subset_row]
        }
    }

    if (is.null(rownames(x))) {
        rownames(x) <- subset_row
    }

    if (scale) {
        if(family$family != "gaussian"){
            stop("scale == TRUE while family is not 'gaussian()'.
                    Scaling should not be done when using count data.
                    If using poisson or
                    negative binomial family, put scale to FALSE.")
        }
        keep <- rv >= 1e-8
        x <- x[keep,,drop=FALSE]/sqrt(rv[keep])
        rv <- rep(1, nrow(x))
    }

    x <- t(x)
    x <- beachmat::realizeFileBackedMatrix(x)

    if (get.var) {
        list(x=x, v=rv)
    } else {
        x
    }
}



