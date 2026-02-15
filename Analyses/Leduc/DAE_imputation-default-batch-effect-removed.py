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


# In[2]:


fn_intensities = ('../../Analyses/Leduc/Output_batch_effect_removal/logintensities_batch_removed.csv')
df = pd.read_csv(fn_intensities, index_col=0)
df = df.T


# In[3]:


df.shape


# In[4]:


start = time.time()
model = AETransformer(
    model='DAE', # or 'VAE'
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

# Save the elapsed time to a .txt file
with open('Output_batch_effect_removal/time_measurement_DAE_default_batch_removed.txt', 'w') as file:
    file.write(f"Elapsed time: {elapsed_time} seconds\n")


df_imputed.to_csv("Output_batch_effect_removal/DAE_default_batch_removed_sce.csv")


# In[6]:


for x in range(1,11):
    fn_intensities = ('../../Analyses/Leduc/Output_batch_effect_removal/logintensities_batch_removed_MISTOT10_MNAR25_' + str(x) + '.csv')
    df = pd.read_csv(fn_intensities, index_col=0)
    df = df.T
    
    start = time.time()
    model = AETransformer(
        model='DAE', # or 'VAE'
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
    
    print(end - start)
    
    df_imputed.to_csv("Output_batch_effect_removal/DAE_default_batch_removed_MISTOT10_MNAR25_" + str(x) + ".csv")



# In[7]:


for x in range(1,11):
    fn_intensities = ('../../Analyses/Leduc/Output_batch_effect_removal/logintensities_batch_removed_MISTOT10_MNAR50_' + str(x) + '.csv')
    df = pd.read_csv(fn_intensities, index_col=0)
    df = df.T
    
    start = time.time()
    model = AETransformer(
        model='DAE', # or 'VAE'
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
    
    print(end - start)
    
    df_imputed.to_csv("Output_batch_effect_removal/DAE_default_batch_removed_MISTOT10_MNAR50_" + str(x) + ".csv")


# In[ ]:





# In[8]:


for x in range(1,11):
    fn_intensities = ('../../Analyses/Leduc/Output_batch_effect_removal/logintensities_batch_removed_MISTOT10_MNAR75_' + str(x) + '.csv')
    df = pd.read_csv(fn_intensities, index_col=0)
    df = df.T
    
    start = time.time()
    model = AETransformer(
        model='DAE', # or 'VAE'
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
    
    print(end - start)
    
    df_imputed.to_csv("Output_batch_effect_removal/DAE_default_batch_removed_MISTOT10_MNAR75_" + str(x) + ".csv")


# In[10]:


df.shape

