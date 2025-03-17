#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import numpy as np
import pandas as pd
from pimmslearn.sklearn.ae_transformer import AETransformer
from pimmslearn.sklearn.cf_transformer import CollaborativeFilteringTransformer
import time
import random

random.seed(10)


# In[ ]:


fn_intensities = ('../../Data/Ecoli_Human/Ecoli_Human_sce.csv')
df = pd.read_csv(fn_intensities, index_col=0)
df = df.T


# In[ ]:


df.head()


# In[ ]:


start = time.time()
model = AETransformer(
    model='DAE', # or 'VAE'
    hidden_layers=[512,],
    latent_dim=3, # dimension of joint sample and item embedding
    batch_size=10,
)


model.fit(df,
          cuda=False,
          epochs_max=100,
          )

df_imputed = model.transform(df)

end = time.time()

print(end - start)


# In[ ]:


df_imputed.to_csv("Output/DAE_sce_3LF.csv")


# In[ ]:


for x in range(1,11):
    fn_intensities = ('../../Data/Ecoli_Human/Ecoli_Human_MISTOT10_MNAR25_' + str(x) + '.csv')
    df = pd.read_csv(fn_intensities, index_col=0)
    df = df.T
    
    start = time.time()
    model = AETransformer(
        model='DAE', # or 'VAE'
        hidden_layers=[512,],
        latent_dim=3, # dimension of joint sample and item embedding
        batch_size=10,
    )
    
    
    model.fit(df,
              cuda=False,
              epochs_max=100,
              )
    
    df_imputed = model.transform(df)
    
    end = time.time()
    
    print(end - start)
    
    df_imputed.to_csv("Output/DAE_MISTOT10_MNAR25_3LF_" + str(x) + ".csv")


# In[ ]:


for x in range(1,11):
    fn_intensities = ('../../Data/Ecoli_Human/Ecoli_Human_MISTOT10_MNAR50_' + str(x) + '.csv')
    df = pd.read_csv(fn_intensities, index_col=0)
    df = df.T
    
    start = time.time()
    model = AETransformer(
        model='DAE', # or 'VAE'
        hidden_layers=[512,],
        latent_dim=3, # dimension of joint sample and item embedding
        batch_size=10,
    )
    
    
    model.fit(df,
              cuda=False,
              epochs_max=100,
              )
    
    df_imputed = model.transform(df)
    
    end = time.time()
    
    print(end - start)
    
    df_imputed.to_csv("Output/DAE_MISTOT10_MNAR50_3LF_" + str(x) + ".csv")


# In[ ]:


for x in range(1,11):
    fn_intensities = ('../../Data/Ecoli_Human/Ecoli_Human_MISTOT10_MNAR75_' + str(x) + '.csv')
    df = pd.read_csv(fn_intensities, index_col=0)
    df = df.T
    
    start = time.time()
    model = AETransformer(
        model='DAE', # or 'VAE'
        hidden_layers=[512,],
        latent_dim=3, # dimension of joint sample and item embedding
        batch_size=10,
    )
    
    
    model.fit(df,
              cuda=False,
              epochs_max=100,
              )
    
    df_imputed = model.transform(df)
    
    end = time.time()
    
    print(end - start)
    
    df_imputed.to_csv("Output/DAE_MISTOT10_MNAR75_3LF_" + str(x) + ".csv")

