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
	python3 Analyses/CPTAC/CF_imputation-default.py
	python3 Analyses/CPTAC/DAE_imputation-default.py
	python3 Analyses/CPTAC/VAE_imputation-default.py

CPTAC_results: CPTAC_analysis
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/imputation_figure_preparation.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/imputation_figure_preparation_lab1.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/DE_analysis.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC/DE_analysis_4labs.Rmd")'




CPTAC_nolab1_preparation:
	Rscript -e 'rmarkdown::render("Data/CPTAC_nolab1/CPTAC_nolab1_data_preparation.Rmd")'	
	
CPTAC_nolab1_analysis: CPTAC_nolab1_preparation
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/Cross_validation.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/Cross_validation_batch.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/Cross_validation_batch_condition.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/SGD_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/SGD_batch_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/SGD_batch_condition_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/nipals_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/NAguideR_analyses.Rmd")'
	python3 Analyses/CPTAC_nolab1/CF_imputation-default.py
	python3 Analyses/CPTAC_nolab1/DAE_imputation-default.py
	python3 Analyses/CPTAC_nolab1/VAE_imputation-default.py
	
CPTAC_nolab1_results: CPTAC_nolab1_analysis
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/imputation_figure_preparation.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/CPTAC_nolab1/DE_analysis.Rmd")'




Petrosius_preparation:
	Rscript -e 'rmarkdown::render("Data/Petrosius/Petrosius_data_preparation.Rmd")'

Petrosius_analysis: Petrosius_preparation
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/Cross_validation.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/Cross_validation_batch.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/SGD_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/SGD_batch_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/nipals_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/NAguideR_analyses.Rmd")'
	python3 Analyses/Petrosius/CF_imputation-default.py
	python3 Analyses/Petrosius/DAE_imputation-default.py
	python3 Analyses/Petrosius/VAE_imputation-default.py
	python3 Analyses/Petrosius/CF_imputation.py
	python3 Analyses/Petrosius/DAE_imputation.py
	python3 Analyses/Petrosius/VAE_imputation.py
	
Petrosius_results: Petrosius_analysis
	Rscript -e 'rmarkdown::render("Analyses/Petrosius/imputation_figure_preparation.Rmd")'




Leduc_preparation:
	Rscript -e 'rmarkdown::render("Data/leduc2022_pSCoPE_data/Leduc_data_preparation.Rmd")'

Leduc_analysis: Leduc_preparation
	Rscript -e 'rmarkdown::render("Analyses/Leduc/Cross_validation.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/Leduc/Cross_validation_batch.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/Leduc/SGD_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/Leduc/SGD_batch_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/Leduc/nipals_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/Leduc/NAguideR_analyses.Rmd")'
	python3 Analyses/Leduc/CF_imputation-default.py
	python3 Analyses/Leduc/DAE_imputation-default.py
	python3 Analyses/Leduc/VAE_imputation-default.py
	python3 Analyses/Leduc/CF_imputation.py
	python3 Analyses/Leduc/DAE_imputation.py
	python3 Analyses/Leduc/VAE_imputation.py
	
Leduc_results: Leduc_analysis
	Rscript -e 'rmarkdown::render("Analyses/Leduc/imputation_figure_preparation.Rmd")'
	
	
	
	
Ecoli_preparation:
	Rscript -e 'rmarkdown::render("Data/Ecoli_Human/Ecoli_Human_data_preparation.Rmd")'
	
Ecoli_analysis: Ecoli_preparation
	Rscript -e 'rmarkdown::render("Analyses/Ecoli_Human/Cross_validation.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/Ecoli_Human/SGD_analyses.Rmd")'
	Rscript -e 'rmarkdown::render("Analyses/Ecoli_Human/NAguideR_analyses.Rmd")'
	python3 Analyses/Ecoli_Human/CF_imputation-default.py
	python3 Analyses/Ecoli_Human/DAE_imputation-default.py
	python3 Analyses/Ecoli_Human/VAE_imputation-default.py
	
Ecoli_results: Ecoli_analysis
	Rscript -e 'rmarkdown::render("Analyses/Ecoli_Human/DE_analysis.Rmd")'



figures: CPTAC_preparation CPTAC_analysis CPTAC_results 
CPTAC_nolab1_preparation CPTAC_nolab1_analysis CPTAC_nolab1_results 
Petrosius_preparation Petrosius_analysis Petrosius_results 
Leduc_preparation Leduc_analysis Leduc_results 
Ecoli_preparation Ecoli_analysis Ecoli_results 
	Rscript -e 'rmarkdown::render("Figures/Figures_manuscript.Rmd")
	
	
clean:
	rm -f Data/*/*.html Data/*/*.pdf Data/*/*.md
	rm -f Analyses/*/*.html Analyses/*/*.pdf Analyses/*/*.json Analyses/*/*.png Analyses/*/*.pkl 
	rm -rf Analyses/*/logs/ Analyses/*/models/
	rm -f Figures/*.html Figures/*.jpeg Figures/*.png

  