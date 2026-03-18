# Exercise 4 Clustering analysis

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
path = 'G:/My Drive/Machine Learning/Classes/SVM'
os.chdir(path)

import gensim.downloader as api

wv = api.load('word2vec-google-news-300')
p=300
corpus = wv.key_to_index
corpus = list(corpus.keys())

vec_king = wv['king']


train_data=pd.read_csv('data/words_data.csv', sep=';')
text1 =train_data['Word'].tolist()
common_elements = list(set(corpus).intersection(set(text1)))


index1 = [text1.index(i) for i in common_elements]
train_data = train_data.iloc[index1]
text1 = [[i] for i in train_data['Word']]

p=300
n = train_data.shape[0]
N = range(0,n)
vector_size=p
X = np.zeros(shape=(n, vector_size))

for i in N:
        X[i,:]= wv[text1[i]]
        

y = train_data.loc[:,'Category'].values
mapping = {'V': 1, 'NV': 0}
y = [mapping[item] for item in y]

  

#split the data set into 80% training and 20% testing
X_train, X_test, y_train, y_test = train_test_split(X, y,
                                                    test_size = 0.2,
                                                    random_state = 0)
# Use SVC (liner kernel)

C_range = np.logspace(-1,1,3)
param_grid = dict(C=C_range)
grid = GridSearchCV(SVC(kernel='linear'), param_grid=param_grid, cv=5)
grid.fit(X_train, y_train)

cost = grid.best_params_
cost = list(cost.values())
cost = cost[0]

svc = SVC(kernel='linear', C=cost)
scores = cross_val_score(svc, X_train, y_train,
                         cv=5, scoring= 'accuracy')
ac_train = np.mean(scores)

svc.fit(X_train, y_train)

ypred = svc.predict(X_test)
ac_test = accuracy_score(ypred, y_test)

print("Accuracy in train with linear kernel: %0.3f"
      %ac_train)

print("Accuracy in test with linear kernel: %0.3f"
      %ac_test)

#use SVC (RBF kernel)
C_range = np.logspace(-1,1,3)
gamma_range = np.logspace(-1,1,3)
param_grid = dict(C=C_range, gamma= gamma_range)
grid = GridSearchCV(SVC(kernel='rbf'), param_grid=param_grid, cv=5)
grid.fit(X_train, y_train)

params = grid.best_params_
params = list(params.values())
cost = params[0]
gamma = params[1]

svc = SVC(kernel='rbf', C=cost, gamma = gamma)
scores = cross_val_score(svc, X_train, y_train,
                         cv=5, scoring= 'accuracy')
ac_train = np.mean(scores)

svc.fit(X_train, y_train)

ypred = svc.predict(X_test)
ac_test = accuracy_score(ypred, y_test)

print("Accuracy in train with radial kernel: %0.3f"
      %ac_train)

print("Accuracy in test with radial kernel: %0.3f"
      %ac_test)
