# scSGDGMF



scSGDGMF is a Bioconductor wrapper for the sgdGMF package. sgdGMF performs matrix factorization and dimensionality reduction for all members of the exponential family. It considers a stochastic gradient descent optimalization for computational efficiency. scSGDGMF allows for:

- Dimensionality reduction directly on (single-cell) RNA-sequencing count data considering a Poisson or negative binomial family. Therefore, no prior normalization is needed as with conventional PCA.
- Dimensionality reduction when dealing with missing data. This makes it suitable for (single-cell) proteomics data when considering a Gaussian family.
- Correction of sample-level (e.g. batch effects) and feature-level covariates (e.g. GC-content). Therefore, the dimensionality reduction obtained is useful when visualizing or clustering cells in which technical variability is present.
- Imputation of missing values by the estimated means, which also take into account the known covariates.

For more information, be sure to check out:
- arXiv preprint on the technical manuscript of sgdGMF, applied to single-cell RNA-sequencing: https://arxiv.org/abs/2412.20509
- bioRxiv preprint on sgdGMF applied to proteomics data for dimensionality reduction and imputation of missing values:



## Installation instructions

To install the development version, run;

```{r 'install_dev', eval = FALSE}
devtools::install_github("statOmics/scSGDGMF")
```

The installation should only take a few seconds.
The dependencies of the package are listed in the DESCRIPTION file of the package.

scSGDGMF is submitted to Bioconductor and should be soon available. 

## Issues and bug reports

Please use https://github.com/statOmics/scSGDGMF/issues to submit issues, bug reports, and comments.


