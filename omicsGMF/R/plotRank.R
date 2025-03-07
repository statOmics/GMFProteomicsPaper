#' Functions to create a scree plot for model selection.
#'
#' @param x Output of \link{sgdgmf.rank}, \link{calculateRankGMF} or
#' \link{runRankGMF}.
#' @param ... For the \code{screeplot_rank} generic, additional arguments to
#' pass to specific methods.
#' @param maxcomp Numeric scalar indicating the number of eigenvalues to plot.
#' @param type Type of scree plot to make: choose between 'point', 'barplot'
#' or 'lines.
#' @param name String specifying the name to be used to obtain the rank object
#' in the \code{\link{metadata}}.
#' @details This function plots a screeplot based on the output of
#' \link{runRankGMF} or \link{sgdgmf.rank}.
#'
#' @return
#' A \link{plot} object.
#' @name plotRank
#' @seealso
#' \code{\link{runRankGMF}}, to calculate the eigenvalues.
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


# adapted dfrom stats:::screeplot.default
#' @importFrom grDevices dev.flush dev.hold
#' @importFrom graphics axis barplot plot
.screeplot_rank <- function (x,
                             maxcomp = length(x$lambdas),
                             type = c("point", "barplot", "lines"),
                             ...)
{


    type <- match.arg(type)
    pcs <- x$lambdas
    xp <- seq_len(maxcomp)
    dev.hold()
    on.exit(dev.flush())
    if (type == "barplot")
        barplot(pcs[xp], names.arg = names(pcs[xp]),
                ylab = "Eigenvalues", ...)
    else if (type == "lines"){
        plot(xp, pcs[xp], type = "b", axes = FALSE,
             xlab = "", ylab = "Eigenvalues", ...)
        axis(2)
        axis(1, labels = names(pcs[xp]))
    } else{
        plot(xp, pcs[xp], type = "p", axes = FALSE,
             xlab = "", ylab = "Eigenvalues", ...)
        axis(2)
        axis(1, labels = names(pcs[xp]))
    }
    invisible()
}


#' @export
#' @rdname plotRank
setMethod("screeplot_rank", "ANY", .screeplot_rank)


#' @export
#' @rdname plotRank
#' @importFrom S4Vectors metadata
plotRank <-  function(x, ..., name = "rank_GMF")
{

    screeplot_rank(x = S4Vectors::metadata(x)[[name]],
                   ...)
}




