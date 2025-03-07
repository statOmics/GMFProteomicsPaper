#' Functions to create a scree plot for model selection.
#'
#' @param x Output of \link{sgdgmf.cv}, \link{calculateCVGMF} or
#' \link{runCVGMF}.
#' @param ... For the \code{plot_cv} generic, additional arguments to
#' pass to specific methods.
#' @param name String specifying the name to be used to obtain the
#'  cross-validation table object in the \code{\link{metadata}}. It is possible
#'  to specify multiple names if multiple cross-validations have been ran.
#' @param method Function for summarization of the cross-validation over
#' multiple folds. Default is mean.
#' @param criteria The model selection criteria that is plotted. Default is
#' 'dev' (deviance residuals), but 'mae', 'mse', 'aic' and 'bic are possible.
#' @details This function plots a screeplot based on the output of
#' \link{runCVGMF}, \link{calculateCVGMF} or \link{sgdgmf.cv}.
#'
#' @return
#' A \link{plot} object.
#' @name plotCV
#' @seealso
#' \code{\link{runCVGMF}}, to perform the cross-validation.
#' @author Alexandre Segers
#'
#' @examples
#' example_sce <- mockSCE(ncells = 200, ngenes = 100)
#' example_sce <- runCVGMF(example_sce,
#'                          exprs_values="counts",
#'                          family = poisson(),
#'                          ncomponents = c(1:5))
#' plotCV(example_sce)
NULL


#' @importFrom stats aggregate
#' @import ggplot2
.plot_cv <- function (x,
                      method = "mean",
                      criteria = "dev")
{
    if(is.null(x$method)){
        x$method <- "cv_GMF"
    }
    cv_summarized <- aggregate(x = x[,criteria],
                               by = list("Method" = x$method, "ncomp" = x$ncomp),
                               FUN = method)

    ggplot(data = cv_summarized, aes(x = ncomp, y = x, col = Method, group = Method)) +
        geom_point() +
        geom_line() +
        theme_bw() +
        ylab(paste0("Out of sample ", criteria)) +
        xlab("number of components")

}


#' @export
#' @rdname plotCV
setMethod("plot_cv", "ANY", .plot_cv)


#' @export
#' @rdname plotCV
#' @importFrom S4Vectors metadata
plotCV <-  function(x, ..., name = "cv_GMF")
{
    cv_list <- lapply(name, FUN = function(i){
        cbind(S4Vectors::metadata(x)[[i]], "method" = i)
    })

    cv_table <- do.call(rbind, cv_list)

    plot_cv(x = cv_table,
           ...)
}




