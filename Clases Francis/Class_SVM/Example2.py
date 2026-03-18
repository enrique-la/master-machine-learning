 #Exercise 2 SVM

#Clean environment and commmand line
from IPython import get_ipython
get_ipython().run_line_magic('reset','-f')
get_ipython().run_line_magic('clear','-f')

# Import the modules

import warnings
import numpy as np
import difflib
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score


# Ignore warnings
warnings.filterwarnings("ignore")




def max_overlap(a1, a2):
    s = difflib.SequenceMatcher(None, a1, a2)
    pos_a, pos_b, size = s.find_longest_match(0, len(a1), 0, len(a2)) 
    return size

X = ["Barca", "Real Madrid", "Madrid", "Barcelona"] 
y = [0, 1, 1, 0]
n = len(y)
R = np.zeros(shape=(n,n))
for i in range(n):
    for j in range(n):
        R[i,j] = max_overlap(X[i], X[j])


svc = SVC(kernel='precomputed')
svc1 = svc.fit(R, y)
svc1.score(R, y)

X_test = ["FCBarcelona", "Real Madrid CF"] 
y_test = [0, 1]
n_test = len(y_test)
R_test= np.zeros(shape=(n_test,n))
for i in range(n_test):
    for j in range(n):
        R_test[i,j] = max_overlap(X_test[i], X[j])
        
ypred = svc1.predict(R_test)
ac_test = accuracy_score(ypred, y_test)
print("Accuracy in test: %0.3f"
      %ac_test)
