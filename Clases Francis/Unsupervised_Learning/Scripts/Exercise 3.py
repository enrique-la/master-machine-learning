# Exercise 3 Clustering analysis

#Clean environment and commmand line
from IPython import get_ipython
get_ipython().run_line_magic('reset','-f')
get_ipython().run_line_magic('clear','-f')

# Import the modules
import numpy as np
import warnings
from sklearn.cluster import KMeans, SpectralClustering
import pylab as plt

# Ignore warnings
warnings.filterwarnings("ignore")

# Generate data

X =  np.array([2,3,4,12,13,14,0,3,0,0,3,0])
X = np.reshape(X, (2,6))
X = np.transpose(X)

# Hierarchical Clustering

from scipy.cluster.hierarchy import dendrogram, linkage
linkage_data = linkage(X, method='complete', metric='euclidean')
names = ['Drug1', 'Drug2', 'Drug3', 'Drug4', 'Drug5', 'Drug6']
dendrogram(linkage_data, labels=names)
plt.show()


# K-means algorithm

nclusters = 5
Nc = range(2, nclusters + 1)
from sklearn.metrics import silhouette_score
silhouette = np.zeros(nclusters-1)
score = np.zeros(nclusters-1)

for i in Nc:
    
    cluster1 = KMeans(n_clusters=i, n_init="auto", random_state=10)
    labels = cluster1.fit_predict(X)
    silhouette[i-2] = silhouette_score(X, labels)
    score[i-2] = -cluster1.fit(X).score(X)


score = np.asarray(score)
silhouette = np.asarray(silhouette)

plt.plot(Nc,score)
plt.xlabel('Number of Clusters')
plt.ylabel('Score')

x = np.linspace(2,nclusters,nclusters-1)
plt.xticks(x)
plt.title('Elbow Curve')
plt.show()

plt.plot(Nc,silhouette)
plt.xlabel('Number of Clusters')
plt.ylabel('Score')

x = np.linspace(2,nclusters,nclusters-1)
plt.xticks(x)
plt.title('Silhouette Index')
plt.show()

# Spectral Clustering

for i in Nc:
    
    cluster1 = SpectralClustering(n_clusters=i,
                                  assign_labels='kmeans',
                                  random_state=10)
    labels = cluster1.fit_predict(X)
    silhouette[i-2] = silhouette_score(X, labels)

silhouette = np.asarray(silhouette)



plt.plot(Nc,silhouette)
plt.xlabel('Number of Clusters')
plt.ylabel('Score')

x = np.linspace(2,nclusters,nclusters-1)
plt.xticks(x)
plt.title('Silhouette Index')
plt.show()

# Spectral Clustering

for i in Nc:
    
    cluster1 = SpectralClustering(n_clusters=i, 
                                  assign_labels='kmeans',
                                  affinity='nearest_neighbors',
                                  n_neighbors=3,
                                  random_state=10)
    labels = cluster1.fit_predict(X)
    silhouette[i-2] = silhouette_score(X, labels)

silhouette = np.asarray(silhouette)



plt.plot(Nc,silhouette)
plt.xlabel('Number of Clusters')
plt.ylabel('Score')

x = np.linspace(2,nclusters,nclusters-1)
plt.xticks(x)
plt.title('Silhouette Index')
plt.show()


# Calculate Laplacian matrix and eigenvectors
a = np.exp(-10)
b = np.exp(-4)
G = np.zeros((6,6))
W = np.zeros((6,6))
L = np.zeros((6,6))
G[0,0]=a +b; G[1,1]=2*a; G[2,2]=a +b; G[3,3]=a +b; G[4,4]=2*a; G[5,5]=a +b;
W[0,1]=a; W[0,2]=b; W[1,0]=a; W[1,2]=a;W[2,0]=b; W[2,1]=a;
W[3,4]=a; W[3,5]=b; W[4,3]=a; W[4,5]=a;W[5,3]=b; W[5,4]=a;
L = G-W
# Calculate eigenvectors and eigenvalues
eigenvalues, eigenvectors = np.linalg.eig(L)


# Create a matrix
a = np.exp(-10)
b = np.exp(-4)
c = np.exp(-20)
G = np.zeros((6,6))
W = np.zeros((6,6))
L = np.zeros((6,6))
G[0,0]=a +b+c; G[1,1]=2*a; G[2,2]=a +b; G[3,3]=a +b +c; G[4,4]=2*a; G[5,5]=a +b;
W[0,1]=a; W[0,2]=b; W[1,0]=a; W[1,2]=a;W[2,0]=b; W[2,1]=a;
W[3,4]=a; W[3,5]=b; W[4,3]=a; W[4,5]=a;W[5,3]=b; W[5,4]=a;
W[0,3]= c; W[3,0]= c;
L = G-W
# Calculate eigenvectors and eigenvalues
eigenvalues, eigenvectors = np.linalg.eig(L)
