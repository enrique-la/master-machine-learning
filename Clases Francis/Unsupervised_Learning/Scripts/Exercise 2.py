# Example Mixture Modeling

#Clean environment and commmand line
from IPython import get_ipython
get_ipython().run_line_magic('reset','-f')
get_ipython().run_line_magic('clear','-f')

# Import modules
import warnings
from sklearn.datasets import make_blobs
import numpy as np
import matplotlib.pyplot as plt
import math

# Ignore warnings
warnings.filterwarnings("ignore")

# Generate data
n = 1000;
c = 1;
std = 0.1;
p = 1;
mean1 = 2;
center_box = (mean1,mean1)

X1, y1_true = make_blobs(n_samples=n, centers=c,
                       cluster_std=std, random_state=1, n_features=p,
                       center_box= center_box)




plt.hist(X1[:, 0], bins= round(math.sqrt(n)), density=True)
mean1 = np.mean(X1[y1_true==0])


n = 500
mean2 = 2.5;
center_box = (mean2,mean2)

X2, y2_true = make_blobs(n_samples=n, centers=c,
                       cluster_std=std, random_state=1, n_features=p,
                       center_box= center_box)

y2_true[:]=1
plt.hist(X2[:, 0], bins= round(math.sqrt(n)), density=True)

X1 = np.array(X1)
X2 = np.array(X2)
X = np.append(X1,X2)
X = np.array(X).reshape(-1,1)
y_true = np.append(y1_true,y2_true)

plt.hist(X[:, 0], bins= round(math.sqrt(1500)), density=True);

from sklearn.mixture import GaussianMixture

gmm = GaussianMixture(n_components=2).fit(X)
print(gmm.means_)
print(gmm.weights_)
print(gmm.covariances_)

pred_means = gmm.means_
variance = gmm.covariances_

mu1 = pred_means[0]
sigma1 = math.sqrt(variance[0])
x1 = np.linspace(mu1 - 3*sigma1, mu1 + 3*sigma1, 100)
import scipy.stats as stats
plt.plot(x1, stats.norm.pdf(x1, mu1, sigma1))


mu2 = pred_means[1]
sigma2 = math.sqrt(variance[1])
x2 = np.linspace(mu2 - 3*sigma2, mu2 + 3*sigma2, 100)
plt.plot(x2, stats.norm.pdf(x2, mu2, sigma2))
plt.show()

# Calculate bimodal index for this case



