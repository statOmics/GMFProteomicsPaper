# Creating a mock SingleCellExperiment
set.seed(100)
library(scSGDGMF)

sce <- scuttle::mockSCE(ncells = 200, ngenes = 100)

# Removing alternative experiments
SingleCellExperiment::altExps(sce) <- NULL

# Create Gaussian experiment
sce <- scater::logNormCounts(sce)

# Create proteomics data with missing values
assay(sce, "logintensities") <- assay(sce, "logcounts")
assay(sce, "logintensities")[assay(sce, "logintensities") == 0] <- NA
