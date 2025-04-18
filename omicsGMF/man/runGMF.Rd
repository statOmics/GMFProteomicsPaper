% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/runGMF.R
\name{calculateGMF}
\alias{calculateGMF}
\alias{runGMF}
\alias{calculateGMF,ANY-method}
\alias{calculateGMF,SummarizedExperiment-method}
\alias{calculateGMF,SingleCellExperiment-method}
\alias{calculateGMF,QFeatures-method}
\alias{runGMF,SummarizedExperiment-method}
\alias{runGMF,SingleCellExperiment-method}
\alias{runGMF,QFeatures-method}
\title{Perform a stochastic gradient descent generalized matrix factorization
(sgdGMF) on cells or bulk samples, based on the expression or mass
spectrometry data in a SingleCellExperiment, SummarizedExperiment or
QFeatures object.}
\usage{
calculateGMF(x, ...)

runGMF(x, ...)

\S4method{calculateGMF}{ANY}(
  x,
  family = gaussian(),
  ncomponents = 50,
  ntop = NULL,
  X = NULL,
  Z = NULL,
  offset = NULL,
  weights = NULL,
  subset_row = NULL,
  scale = FALSE,
  transposed = FALSE,
  BSPARAM = bsparam(),
  BPPARAM = SerialParam(),
  control.init = list(),
  control.alg = list(),
  crossval = FALSE,
  control.cv = list(),
  penalty = list(),
  method = "sgd",
  sampling = "block"
)

\S4method{calculateGMF}{SummarizedExperiment}(
  x,
  ...,
  exprs_values = 1,
  assay.type = exprs_values,
  family = gaussian()
)

\S4method{calculateGMF}{SingleCellExperiment}(
  x,
  ...,
  exprs_values = 1,
  dimred = NULL,
  n_dimred = NULL,
  assay.type = exprs_values,
  family = gaussian()
)

\S4method{calculateGMF}{QFeatures}(
  x,
  ...,
  exprs_values = NULL,
  dimred = NULL,
  n_dimred = NULL,
  assay.type = NULL,
  family = gaussian()
)

\S4method{runGMF}{SummarizedExperiment}(x, ...)

\S4method{runGMF}{SingleCellExperiment}(x, ..., altexp = NULL, name = "GMF")

\S4method{runGMF}{QFeatures}(x, ..., exprs_values = NULL, assay.type = NULL)
}
\arguments{
\item{x}{For \code{calculateGMF}, a numeric matrix of expression counts or
mass spectrometry intensities where rows are features and columns are cells.

Alternatively, a \linkS4class{SummarizedExperiment},
\linkS4class{SingleCellExperiment} or \link[QFeatures]{QFeatures} object
containing such a matrix.}

\item{...}{For the \code{calculateGMF} generic, additional arguments to
pass to specific methods.
For the SummarizedExperiment and SingleCellExperiment methods, additional
arguments to pass to the ANY method. For the QFeatures method, additional
arguments to pass to the SingleCellExperiment method.

For \code{runGMF}, additional arguments to pass to \code{calculateGMF}.}

\item{family}{The distribution family that is used for the estimation of
the parameters.}

\item{ncomponents}{Numeric scalar indicating the number of principal
components to estimate.}

\item{ntop}{Numeric scalar specifying the number of features with the
highest variances to use for dimensionality reduction.
Default uses all features.}

\item{X}{Sample-level covariate matrix. Defaults to column of ones.}

\item{Z}{Feature-level covariate matrix. Defaults to column of ones.}

\item{offset}{offset matrix with same dimensions as x that is added to the
linear predictor. Note that if family = poisson(), this should therefore be
on the log-scale.}

\item{weights}{weight matrix with same dimensions as x that determines the
weight of each observation.}

\item{subset_row}{Vector specifying the subset of features to use for
dimensionality reduction.
This can be a character vector of row names, an integer vector of row
indices or a logical vector.}

\item{scale}{Logical scalar, should the expression values be standardized?
Not recommended for non-Gaussian data.}

\item{transposed}{Logical scalar, is \code{x} transposed with cells in rows?}

\item{BSPARAM}{A \linkS4class{BiocSingularParam} object specifying which
algorithm should be used to perform the PCA.
This is used in \code{runPCA} to put all information in the sample latent
factors.}

\item{BPPARAM}{A \linkS4class{BiocParallelParam} object specifying whether
the initialization and cross-validation should be parallelized.}

\item{control.init}{control parameters for the initialization, used in the
\code{sgdGMF} package. See \link{sgdgmf.init} and \link{set.control.init}.}

\item{control.alg}{control parameters for the estimation, used in the
\code{sgdGMF} package. See \link{sgdgmf.fit} and \link{set.control.alg}.}

\item{crossval}{if TRUE, performs cross-validation followed by fitting a
final model with the optimal number of components.
Generally not recommended, as no quality control of the cross-validation
is done before the final fit.
See \link{calculateCVGMF} for cross-validation.}

\item{control.cv}{control parameters for the cross-validation, used in the
\code{sgdGMF} package. See \link{sgdgmf.cv} and \link{set.control.cv}.}

\item{penalty}{ridge penalty added for the estimation of the parameters in
the \code{sgdGMF} package. see \link{sgdgmf.fit}.}

\item{method}{estimation algorithm from the \code{sgdGMF} package used.
See \link{sgdgmf.fit}. Defaults to 'sgd' for a stochastic gradient
descent optimization.}

\item{sampling}{sub-sampling strategy to use if method = "sgd". See
\link{sgdgmf.fit} from the \code{sgdGMF} package. Defaults to 'block'
for a block-wise stochastic gradient descent optimization.}

\item{exprs_values}{Alias to \code{assay.type}.}

\item{assay.type}{Integer scalar or string indicating which assay of
\code{x} contains the values of interest.}

\item{dimred}{String or integer scalar specifying the existing
dimensionality reduction results to use.}

\item{n_dimred}{Integer scalar or vector specifying the dimensions to
use if \code{dimred} is specified.}

\item{altexp}{String or integer scalar specifying an alternative experiment
containing the input data.}

\item{name}{String specifying the name to be used to store the result in
the \code{\link{reducedDims}} of the output.}
}
\value{
This section is adapted from the \code{scater} package manual.

For \code{calculateGMF}, a numeric matrix of coordinates for each cell
(row) in each of \code{ncomponents} PCs (column).

For \code{runGMF}, a SingleCellExperiment object is returned containing
this matrix in \code{\link{reducedDims}(..., name)}.

In both cases, the attributes of the PC coordinate matrix contain the
following elements:
\itemize{
\item \code{"rotation"}, the rotation matrix containing loadings for all
features used in the analysis and for each PC.
\item \code{"X"}, the known sample-level covariate matrix.
\item \code{"Beta"}, the estimated parameters related to the known
sample-level covariate matrix.
\item \code{"Z"}, the known feature-level covariate matrix.
\item \code{"Gamma"}, the estimated parameters related to the known
feature-level covariate matrix.
\item \code{"family"}, the distribution family used for the estimation of
the parameters.
\item \code{"trace"}, a trace matrix recording the optimization history of
sgdGMF.
\item \code{"summary.cv"}, only if cross-validation was performed, a
summary table of the cross-validation.
\item \code{"offset"}, only if offset is not NULL, a matrix containing the
offsets.
}
}
\description{
Perform a stochastic gradient descent generalized matrix factorization
(sgdGMF) on cells or bulk samples, based on the expression or mass
spectrometry data in a SingleCellExperiment, SummarizedExperiment or
QFeatures object.
}
\details{
sgdGMF uses sampling of the data to estimate the parameters, which can
alter with different seeds.
This means that the result will change slightly across different runs.
For full reproducibility, users should call \code{\link{set.seed}} prior to
running \code{runGMF} with such algorithms.
(Note that this includes \code{BSPARAM=\link{bsparam}()}, which uses
approximate algorithms by default.)
}
\section{Feature selection}{

This section is adapted from the \code{scater} package manual.

This section is relevant if \code{x} is a numeric matrix with features in
rows and cells in columns;
or if \code{x} is a \linkS4class{SingleCellExperiment} and
\code{dimred=NULL}.
In the latter, the expression values are obtained from the assay specified
by \code{assay.type}.

The \code{subset_row} argument specifies the features to use for
dimensionality reduction.
The aim is to allow users to specify highly variable features to improve
the signal/noise ratio,
or to specify genes in a pathway of interest to focus on particular
aspects of heterogeneity.

If \code{subset_row=NULL}, the \code{ntop} features with the largest
variances are used instead.
We literally compute the variances from the expression values without
considering any mean-variance trend, nor considering missing values,
so often a more considered choice of genes is possible, e.g., with
\pkg{scran} functions.
Note that the value of \code{ntop} is ignored if \code{subset_row} is
specified.

If \code{scale=TRUE}, the expression values for each feature are
standardized so that their variance is unity.
This will also remove features with standard deviations below 1e-8. This
is not recommended when using non-Gaussian family distributions.
}

\section{Using reduced dimensions}{

This section is adapted from the \code{scater} package manual.

If \code{x} is a \linkS4class{SingleCellExperiment}, the method can be
applied on existing dimensionality reduction results in \code{x} by setting
the \code{dimred} argument.

The matrix of existing reduced dimensions is taken from
\code{\link{reducedDim}(x, dimred)}.
By default, all dimensions are used to compute the second set of reduced
dimensions.
If \code{n_dimred} is also specified, only the first \code{n_dimred}
columns are used.
Alternatively, \code{n_dimred} can be an integer vector specifying the
column indices of the dimensions to use.

When \code{dimred} is specified, no additional feature selection or
standardization is performed.
This means that any settings of \code{ntop}, \code{subset_row} and
\code{scale} are ignored.

If \code{x} is a numeric matrix, setting \code{transposed=TRUE} will treat
the rows as cells and the columns as the variables/diemnsions.
This allows users to manually pass in dimensionality reduction results
without needing to wrap them in a \linkS4class{SingleCellExperiment}.
As such, no feature selection or standardization is performed, i.e.,
\code{ntop}, \code{subset_row} and \code{scale} are ignored.
}

\section{Using alternative Experiments}{


This section is adapted from the \code{scater} package manual.

This section is relevant if \code{x} is a
\linkS4class{SingleCellExperiment} and \code{altexp} is not \code{NULL}.
In such cases, the method is run on data from an alternative
\linkS4class{SummarizedExperiment} nested within \code{x}.
This is useful for performing dimensionality reduction on other features
stored in \code{\link{altExp}(x, altexp)}, e.g., antibody tags.

Setting \code{altexp} with \code{assay.type} will use the specified assay
from the alternative \linkS4class{SummarizedExperiment}.
If the alternative is a SingleCellExperiment, setting \code{dimred} will
use the specified dimensionality reduction results from the alternative.
This option will also interact as expected with \code{n_dimred}.

Note that the output is still stored in the \code{\link{reducedDims}} of
the output SingleCellExperiment.
It is advisable to use a different \code{name} to distinguish this output
from the results generated from the main experiment's assay values.
}

\examples{
example_sce <- mockSCE(ncells = 200, ngenes = 100)
example_sce <- runCVGMF(example_sce,
                         exprs_values="counts",
                         family = poisson(),
                         ncomponents = c(1:5))
example_sce <- runGMF(example_sce,
                      exprs_values="counts",
                      family = poisson(),
                      ncomponents = 3)
reducedDimNames(example_sce)
head(reducedDim(example_sce))
}
\seealso{
\code{\link[sgdGMF]{sgdgmf.fit}}, for the underlying calculations.

\code{\link[omicsGMF]{plotGMF}}, to conveniently visualize the results.
\code{\link[omicsGMF]{imputeGMF}}, to conveniently impute missing values.
}
\author{
Alexandre Segers
}
