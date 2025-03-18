all: CPTAC_preparation CPTAC_analysis CPTAC_results 
CPTAC_nolab1_preparation CPTAC_nolab1_analysis CPTAC_nolab1_results 
Petrosius_preparation Petrosius_analysis Petrosius_results 
Leduc_preparation Leduc_analysis Leduc_results 
Ecoli_preparation Ecoli_analysis Ecoli_results 
figures




CPTAC_preparation:
	Rscript -e 'rmarkdown::render("Data/CPTAC_data/CPTAC_data_preparation.Rmd")'

CPTAC_analysis: CPTAC_preparation
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/Cross_validation.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/Cross_validation_batch.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/Cross_validation_batch_condition.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/SGD_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/SGD_batch_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/SGD_batch_condition_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/nipals_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/NAguideR_analyses.Rmd")'
	
CPTAC_results: CPTAC_analysis
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/imputation_figure_preparation.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/imputation_figure_preparation_lab1.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/DE_analysis.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/DE_analysis_4labs.Rmd")'




CPTAC_nolab1_preparation:
	Rscript -e 'rmarkdown::render("Data/CPTAC_nolab1/CPTAC_nolab1_data_preparation.Rmd")	
	
CPTAC_nolab1_analysis: CPTAC_nolab1_preparation
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/Cross_validation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/Cross_validation_batch.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/Cross_validation_batch_condition.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/SGD_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/SGD_batch_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/SGD_batch_condition_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/nipals_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/NAguideR_analyses.Rmd")
	
CPTAC_nolab1_results: CPTAC_nolab1_analysis
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/imputation_figure_preparation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/DE_analysis.Rmd")




Petrosius_preparation:
  Rscript -e 'rmarkdown::render("Data/Petrosius/Petrosius_data_preparation.Rmd")

Petrosius_analysis: Petrosius_preparation
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/Cross_validation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/Cross_validation_batch.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/SGD_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/SGD_batch_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/nipals_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/NAguideR_analyses.Rmd")
	
Petrosius_results: Petrosius_analysis
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/imputation_figure_preparation.Rmd")




Leduc_preparation:
	Rscript -e 'rmarkdown::render("Data/leduc2022_pSCoPE_data/Leduc_data_preparation.Rmd")

Leduc_analysis: Leduc_preparation
	Rscript -e 'rmarkdown::render("Analyses/Leduc/Cross_validation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Leduc/Cross_validation_batch.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Leduc/SGD_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Leduc/SGD_batch_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Leduc/nipals_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Leduc/NAguideR_analyses.Rmd")
	
Leduc_results: Leduc_analysis
	Rscript -e 'rmarkdown::render("Analyses/Leduc/imputation_figure_preparation.Rmd")
	
	
	
	
Ecoli_preparation:
	Rscript -e 'rmarkdown::render("Data/Ecoli_Human/Ecoli_Human_data_preparation.Rmd")
	
Ecoli_analysis: Ecoli_preparation
	Rscript -e 'rmarkdown::render("Analyses/Ecoli_Human/Cross_validation.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Ecoli_Human/SGD_analyses.Rmd")
	Rscript -e 'rmarkdown::render("Analyses/Ecoli_Human/NAguideR_analyses.Rmd")
	
Ecoli_results: Ecoli_analysis
	Rscript -e 'rmarkdown::render("Analyses/Ecoli_Human/DE_analysis.Rmd")



figures: CPTAC_preparation CPTAC_analysis CPTAC_results 
CPTAC_nolab1_preparation CPTAC_nolab1_analysis CPTAC_nolab1_results 
Petrosius_preparation Petrosius_analysis Petrosius_results 
Leduc_preparation Leduc_analysis Leduc_results 
Ecoli_preparation Ecoli_analysis Ecoli_results 
	Rscript -e 'rmarkdown::render("Figures/Figures_manuscript.Rmd")
  