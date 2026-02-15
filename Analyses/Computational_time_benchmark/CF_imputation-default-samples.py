#!/usr/bin/env python
# coding: utf-8

# In[3]:


import numpy as np
import pandas as pd
from pimmslearn.sklearn.ae_transformer import AETransformer
from pimmslearn.sklearn.cf_transformer import CollaborativeFilteringTransformer
import time
import random

random.seed(10)


# In[1]:


import os

os.environ["OMP_NUM_THREADS"] = "1"
os.environ["OPENBLAS_NUM_THREADS"] = "1"
os.environ["MKL_NUM_THREADS"] = "1"
os.environ["VECLIB_MAXIMUM_THREADS"] = "1"
os.environ["NUMEXPR_NUM_THREADS"] = "1"


# In[2]:


index_name = 'Sample ID'
column_name = 'protein group'
value_name = 'intensity'


# In[6]:


fixed_feature = 5000
fixed_sample = 1000
fixed_dim = 10

for x in [100, 1000, 10000, "1e+05"]:
    fn_intensities = ('../../Data/Computational_time_benchmark/simulated_' + str(fixed_feature) + '_features_' + str(x) + '_samples_nocolnames.csv')
    df = pd.read_csv(fn_intensities, index_col=0)
    df = df.T
    
    start = time.time()

    df.index.name = index_name  # already set
    df.columns.name = column_name

    series = df.stack()
    series.name = value_name  # ! important
    model = CollaborativeFilteringTransformer(
        target_column=value_name,
        sample_column=index_name,
        item_column=column_name,
        n_factors=50, # dimension of separate sample and item embedding
        batch_size = 4096
    )
    
    model.fit(series, cuda=False, epochs_max=20)
    df_imputed = model.transform(series).unstack()
    
    end = time.time()
    
    elapsed_time = end - start
    print(elapsed_time)

    # Save the elapsed time to a .txt file
    with open('Output/time_measurement_CF_default_' + str(fixed_feature) + '_features_' + str(x) + '.txt', 'w') as file:
        file.write(f"Elapsed time: {elapsed_time} seconds\n")

    
    df_imputed.to_csv('Output/CF_default_' + str(fixed_feature) + '_features_' + str(x) + '_samples.csv')



