# GMFProteomicsPaper

Repository for the paper using sgdGMF for dimensionality reduction, 
batch effect removal and imputation of missing values for mass-spectrometry 
based proteomics data. The bioRxiv preprint is available at: 


## Setup and preprocessing of data

First, all the data are downloaded and preprocessed. The data for the CPTAC and Ecoli data
are already available through the github download of this repository. 
Then, one can download the other datasets and continue the preprocessing these
based on the scripts under `Data/`. Using the Makefile, this can be achieved by
using `make CPTAC_preparation`, `make CPTAC_nolab1_preparation`, `make Petrosius_preparation`,
`make Leduc_preparation` and `make Ecoli_preparation`.

## Analysis using different methods

Then, one can proceeds to run all the analyses on the different datasets. These scripts
are situated under `Analyses/`, followed by the directory of the respective dataset. Here,
not only R-scripts are used, but also python scripts for the PIMMS imputation methods.
Using the Makefile, this can be achieved by
using `make CPTAC_analysis`, `make CPTAC_nolab1_analysis`, `make Petrosius_analysis`,
`make Leduc_analysis` and `make Ecoli_analysis`.


## Summarizing the imputation results and DE-analysis

Then, one can summarize the imputation results of all different seeds and perform DE-analyses
for the CPTAC and \it{E. coli} dataset. These scripts are also situated under `Analyses/`, 
followed by the directory of the respective dataset. Using the Makefile, this can be achieved by
using `make CPTAC_results`, `make CPTAC_nolab1_results`, `make Petrosius_results`,
`make Leduc_results` and `make Ecoli_results`.


## Making all the figures of the manuscript

To replicate all the figures of the manuscript, one can run the script
`Figures/Figures_manuscript.Rmd`. Alternatively, using make this is possible by
using `make figures`.

## Run the project:

The code can be run by executing the different scripts directly or through the Makefile. 
Using make, you can execute the full project using `make all`.

