all: make preprocessing crossvalidation analyses DEanalyses figures

CPTAC:
	Rscript -e 'rmarkdown::render("Data/CPTAC_data/CPTAC_data_preparation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/Cross_validation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/Cross_validation_batch.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/Cross_validation_batch_condition.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/Cross_validation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/SGD_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/SGD_batch_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/SGD_batch_condition_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/nipals_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/SGD_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/NAguideR_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/imputation_figure_preparation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/imputation_figure_preparation_lab1.Rmd")


CPTAC_nolab1:
	Rscript -e 'rmarkdown::render("Data/CPTAC_nolab1/CPTAC_nolab1_data_preparation.Rmd")
	
Petrosius:
  Rscript -e 'rmarkdown::render("Data/Petrosius/Petrosius_data_preparation.Rmd")
  
Leduc:
	Rscript -e 'rmarkdown::render("Data/leduc2022_pSCoPE_data/Leduc_data_preparation.Rmd")
	
Ecoli:
	Rscript -e 'rmarkdown::render("Data/Ecoli_Human/Ecoli_Human_data_preparation.Rmd")
	
DEanalyses: preprocessing
	Rscript -e 'rmarkdown::render("")
	

figures: preprocessing crossvalidation analyses
	R CMD BATCH benchmark/run_benchmark.R
  