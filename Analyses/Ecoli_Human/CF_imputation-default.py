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
index_name = 'Sample ID'
column_name = 'protein group'
value_name = 'intensity'


# In[ ]:


df.head()


# In[ ]:


start = time.time()



df.index.name = index_name  # already set
df.columns.name = column_name  

series = df.stack()
series.name = value_name  # ! important
model = CollaborativeFilteringTransformer(
    target_column=value_name,
    sample_column=index_name,
    item_column=column_name,
    n_factors=30, # dimension of separate sample and item embedding
    batch_size = 4096
)

model.fit(series, cuda=False, epochs_max=20)
df_imputed = model.transform(series).unstack()




end = time.time()

print(end - start)


# In[ ]:


df_imputed.to_csv("Output/CF_sce.csv")


# In[ ]:


for x in range(1,11):
    fn_intensities = ('../../Data/Ecoli_Human/Ecoli_Human_MISTOT10_MNAR25_' + str(x) + '.csv')
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
        n_factors=30, # dimension of separate sample and item embedding
        batch_size = 4096
    )
    
    model.fit(series, cuda=False, epochs_max=20)
    df_imputed = model.transform(series).unstack()
    
    end = time.time()
    
    print(end - start)
    
    df_imputed.to_csv("Output/CF_MISTOT10_MNAR25_" + str(x) + ".csv")


# In[ ]:


for x in range(1,11):
    fn_intensities = ('../../Data/Ecoli_Human/Ecoli_Human_MISTOT10_MNAR50_' + str(x) + '.csv')
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
        n_factors=30, # dimension of separate sample and item embedding
        batch_size = 4096
    )
    
    model.fit(series, cuda=False, epochs_max=20)
    df_imputed = model.transform(series).unstack()
    
    end = time.time()
    
    print(end - start)
    
    df_imputed.to_csv("Output/CF_MISTOT10_MNAR50_" + str(x) + ".csv")


# In[ ]:


for x in range(1,11):
    fn_intensities = ('../../Data/Ecoli_Human/Ecoli_Human_MISTOT10_MNAR75_' + str(x) + '.csv')
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
        n_factors=30, # dimension of separate sample and item embedding
        batch_size = 4096
    )
    
    model.fit(series, cuda=False, epochs_max=20)
    df_imputed = model.transform(series).unstack()
    
    end = time.time()
    
    print(end - start)
    
    df_imputed.to_csv("Output/CF_MISTOT10_MNAR75_" + str(x) + ".csv")

