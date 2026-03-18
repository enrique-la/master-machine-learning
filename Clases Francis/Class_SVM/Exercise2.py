 #Exercise 2 SVM

#Clean environment and commmand line
from IPython import get_ipython
get_ipython().run_line_magic('reset','-f')
get_ipython().run_line_magic('clear','-f')

# Import the modules
import os
import warnings
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import GridSearchCV

# Ignore warnings
warnings.filterwarnings("ignore")

#Fixed working directory
path = 'G:/My Drive/Machine Learning/Classes/SVM'
os.chdir(path)

# Import data

train=  pd.read_csv('data/MNIST.csv')

y = train.loc[:,'label'].values
X = train.loc[:,'pixel0':].values
n = y.shape[0]

#split the data set into 80% training and 20% testing
X_train, X_test, y_train, y_test = train_test_split(X, y,
                                                    test_size = 0.95,
                                                    random_state = 0)


# Use SVC (liner kernel)

C_range = np.logspace(-1,1,3)

print("Accuracy in train with linear kernel: %0.3f"
      %ac_train)

print("Accuracy in test with linear kernel: %0.3f"
      %ac_test)


#Use SVC (RBF kernel)

C_range = np.logspace(-1,1,3)
gamma_range = np.logspace(-1,1,3)

print("Accuracy in train with radial kernel: %0.3f"
      %ac_train)

print("Accuracy in test with radial kernel: %0.3f"
      %ac_test)

