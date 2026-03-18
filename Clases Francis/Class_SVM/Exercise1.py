
# Exercise 1 SVM

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
from matplotlib import pyplot as plt
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

normal = pd.read_table('data/NB.txt', delimiter=",")
normal['Fault'] = 0
normal = normal[:500]

fail= pd.read_table('data/IR7.txt', delimiter=",")
fail['Fault'] = 1
fail = fail[:500]

dataset = normal.append(fail)


# Removing duplicates if there exist
N_dupli = sum(dataset.duplicated(keep='first'))
dataset = dataset.drop_duplicates(keep='first')
dataset = dataset.reset_index(drop=True)

# Number of samples in the dataset and define X and y
N = dataset.shape[0]
X = dataset.iloc[:, 0:2].values
y = dataset.iloc[:, 2]

#split the data set into 80% training and 20% testing

#split the data set into 80% training and 20% testing
X_train, X_test, y_train, y_test = train_test_split(X, y,
                                                    test_size = 0.2,
                                                    random_state = 0)

# Plot the data

plt.scatter(X_train[:, 0], X_train[:, 1], c=y_train, cmap='winter')
plt.show()

# Use SVC (liner kernel)

C_range = np.logspace(-5,5,11)
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

plt.scatter(X_train[:, 0], X_train[:, 1], c=y_train, cmap='winter');
ax = plt.gca()
xlim = ax.get_xlim()
w = svc.coef_[0]
a = -w[0] / w[1]
xx = np.linspace(xlim[0], xlim[1])
yy = a * xx - svc.intercept_[0] / w[1]
plt.plot(xx, yy)
yy = a * xx - (svc.intercept_[0] - 1) / w[1]
plt.plot(xx, yy, 'k--')
yy = a * xx - (svc.intercept_[0] + 1) / w[1]
plt.plot(xx, yy, 'k--')
plt.show()

#use SVC (RBF kernel)

C_range = np.logspace(-3,3,7)
gamma_range = np.logspace(-3,3,7)
param_grid = dict(C=C_range, gamma= gamma_range)
grid = GridSearchCV(SVC(kernel='rbf'), param_grid=param_grid, cv=5)
grid.fit(X_train, y_train)

tmp = grid.cv_results_
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

from sklearn.inspection import DecisionBoundaryDisplay

feature1, feature2 = np.meshgrid(np.linspace(X_test[:, 0].min(),
                                             X_test[:, 0].max()),
                                   np.linspace(X_test[:, 1].min(),
                                               X_test[:, 1].max()))  

grid = np.vstack([feature1.ravel(), feature2.ravel()]).T  
ypred = np.reshape(svc.predict(grid), feature1.shape)
display = DecisionBoundaryDisplay(xx0=feature1,
                                  xx1=feature2, response=ypred)
display.plot()
display.ax_.scatter( X_test[:, 0], X_test[:, 1], c=y_test, edgecolor="black")
plt.show()


  
  


