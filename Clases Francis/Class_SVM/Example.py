# Example SVM

#Clean environment and commmand line
from IPython import get_ipython
get_ipython().run_line_magic('reset','-f')
get_ipython().run_line_magic('clear','-f')

# Import the modules
import numpy as np
import warnings
from sklearn.datasets import make_blobs
from sklearn.model_selection import train_test_split
from matplotlib import pyplot as plt
from sklearn.metrics import confusion_matrix, accuracy_score
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import GridSearchCV
from sklearn.svm import SVC

# Ignore warnings
warnings.filterwarnings("ignore")


# Generate random data 
X, y = make_blobs(n_samples=250, centers=2,
                  random_state= 0, cluster_std=1)

# Plot data
plt.scatter(X[:, 0], X[:, 1], c=y, cmap='winter')
plt.show()

# Split data into train and test
X_train, X_test, y_train, y_test = train_test_split(X,
                                                    y,
                                                    test_size=0.2,
                                                    random_state=0)

# Train SVC for a particular cost value
svc = SVC(kernel='linear', C=1)
svc.fit(X_train, y_train)

# Plot the solution
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

# Assses predictions
y_pred = svc.predict(X_test)
y_pred_t = svc.predict(X_train)

ac_train = accuracy_score(y_train, y_pred_t)
print("Accuracy in train: %0.3f"
      %ac_train)

ac_test = accuracy_score(y_test, y_pred)
print("Accuracy in test: %0.3f"
      %ac_test)


confusion_matrix(y_test, y_pred)
confusion_matrix(y_train, y_pred_t)

# Fix parameter with GridSearchCV
C_range = np.logspace(-4,4,9)
param_grid = dict(C=C_range)
grid = GridSearchCV(SVC(kernel='linear'),
                    param_grid=param_grid, cv=5)
grid.fit(X_train, y_train)

print(
    "The best parameters are %s with a score of %0.2f"
    % (grid.best_params_, grid.best_score_)
)

# Calculate error train and test error
tmp = grid.cv_results_
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

print("Accuracy in train: %0.3f"
      %ac_train)

print("Accuracy in test: %0.3f"
      %ac_test)


