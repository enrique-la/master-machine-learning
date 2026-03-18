# Exercise 3 Support Vector Machines

#Clean environment and commmand line
from IPython import get_ipython
get_ipython().run_line_magic('reset','-f')
get_ipython().run_line_magic('clear','-f')

# Import the modules
import os
import warnings
import numpy as np
import pandas as pd
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import GridSearchCV
from sklearn.svm import SVC


# Ignore warnings
warnings.filterwarnings("ignore")

#Fixed working directory
path = 'G:/My Drive/Machine Learning/Assignment/2023-2024'
os.chdir(path)

import gensim.downloader as api

wv = api.load('word2vec-google-news-300')
p=300
corpus = wv.key_to_index
corpus = list(corpus.keys())

vec_king = wv['king']

