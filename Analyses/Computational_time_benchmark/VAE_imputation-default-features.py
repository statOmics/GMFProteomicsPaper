#!/usr/bin/env python
# coding: utf-8

# In[1]:


import numpy as np
import pandas as pd
from pimmslearn.sklearn.ae_transformer import AETransformer
from pimmslearn.sklearn.cf_transformer import CollaborativeFilteringTransformer
import time
import random

random.seed(10)


# In[ ]:


import os

os.environ["OMP_NUM_THREADS"] = "1"
os.environ["OPENBLAS_NUM_THREADS"] = "1"
os.environ["MKL_NUM_THREADS"] = "1"
os.environ["VECLIB_MAXIMUM_THREADS"] = "1"
os.environ["NUMEXPR_NUM_THREADS"] = "1"


# In[6]:


fixed_feature = 5000
fixed_sample = 1000
fixed_dim = 10

for x in [100, 1000, 10000, "1e+05"]:
    fn_intensities = ('../../Data/Computational_time_benchmark/simulated_' + str(x) + '_features_' + str(fixed_sample) + '_samples.csv')
    df = pd.read_csv(fn_intensities, index_col=0)
    df = df.T
    
    start = time.time()
    model = AETransformer(
        model='VAE', # or 'VAE'
        hidden_layers=[512,],
        latent_dim=50, # dimension of joint sample and item embedding
        batch_size=10,
    )
    
    
    model.fit(df,
              cuda=False,
              epochs_max=100,
              )
    
    df_imputed = model.transform(df)
    
    end = time.time()
    
    elapsed_time = end - start
    print(elapsed_time)
    
    with open('Output/time_measurement_VAE_default_' + str(x) + '_features_' + str(fixed_sample) + '.txt', 'w') as file:
        file.write(f"Elapsed time: {elapsed_time} seconds\n")

    
    df_imputed.to_csv('Output/VAE_default_' + str(x) + '_features_' + str(fixed_sample) + '_samples.csv')


