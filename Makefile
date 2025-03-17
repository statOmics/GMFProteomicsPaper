all: make preprocessing crossvalidation analyses DEanalyses figures

CPTAC:
	Rscript -e 'rmarkdown::render("Data/CPTAC_data/CPTAC_data_preparation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/Cross_validation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/Cross_validation_batch.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/Cross_validation_batch_condition.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/SGD_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/SGD_batch_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/SGD_batch_condition_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/nipals_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/NAguideR_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/imputation_figure_preparation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/imputation_figure_preparation_lab1.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/DE_analysis.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/DE_analysis_4labs.Rmd")


CPTAC_nolab1:
	Rscript -e 'rmarkdown::render("Data/CPTAC_nolab1/CPTAC_nolab1_data_preparation.Rmd")	
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/Cross_validation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/Cross_validation_batch.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/Cross_validation_batch_condition.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/SGD_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/SGD_batch_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/SGD_batch_condition_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/nipals_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/NAguideR_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/imputation_figure_preparation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/DE_analysis.Rmd")

Petrosius:
  Rscript -e 'rmarkdown::render("Data/Petrosius/Petrosius_data_preparation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/Cross_validation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/Cross_validation_batch.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/SGD_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/SGD_batch_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/nipals_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/NAguideR_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/imputation_figure_preparation.Rmd")

Leduc:
	Rscript -e 'rmarkdown::render("Data/leduc2022_pSCoPE_data/Leduc_data_preparation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Leduc/Cross_validation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Leduc/Cross_validation_batch.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Leduc/SGD_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Leduc/SGD_batch_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Leduc/nipals_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Leduc/NAguideR_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Leduc/imputation_figure_preparation.Rmd")
	
Ecoli:
	Rscript -e 'rmarkdown::render("Data/Ecoli_Human/Ecoli_Human_data_preparation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Ecoli_Human/Cross_validation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Ecoli_Human/SGD_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Ecoli_Human/NAguideR_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Ecoli_Human/DE_analysis.Rmd")

DEanalyses: preprocessing


figures: preprocessing crossvalidation analyses
	R CMD BATCH benchmark/run_benchmark.R
  