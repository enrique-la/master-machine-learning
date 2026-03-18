# Exercise 5 Clustering analysis

#Clean environment and commmand line
from IPython import get_ipython
get_ipython().run_line_magic('reset','-f')
get_ipython().run_line_magic('clear','-f')

# Import the modules
import os
import numpy as np
import pandas as pd
import warnings
from sklearn.cluster import KMeans, SpectralClustering
import pylab as plt
import seaborn as sns

# Ignore warnings
warnings.filterwarnings("ignore")

#Fixed working directory
path = 'G:/Mi unidad/Machine Learning/Classes/Clustering/data'
os.chdir(path)

# Load the data
df = pd.read_csv("dataset_chemicals.txt", delimiter='\t')
X = df.drop(df.columns[[0, 1]], axis = 1).values

from sklearn.preprocessing import StandardScaler
scale = StandardScaler()
#X = scale.fit_transform(X)


# K-means algorithm plus Silhouette Index
nclusters = 30
Nc = range(2, nclusters + 1)
from sklearn.metrics import silhouette_score
silhouette = np.zeros(nclusters-1)

for i in Nc:
    
    cluster1 = KMeans(n_clusters=i, n_init="auto", random_state=10)
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



K=12

clustersol = KMeans(n_clusters=K, n_init="auto", random_state=10)
labelsol = clustersol.fit_predict(X)
labelsol = labelsol + 1


from sklearn.decomposition import PCA
pca = PCA(n_components=2)
components = pca.fit_transform(X)

componentsDf = pd.DataFrame(data = components, columns = ['PC1', 'PC2'])
labelsol = pd.DataFrame(data = labelsol, columns = ['Labels'])
labeldata = pd.DataFrame(data = df, columns = ['Molecule_type'])
pcaDf = pd.concat([componentsDf, labelsol, labeldata], axis=1)
pcaDf['Molecule_type'] = pcaDf['Molecule_type'].apply(str)


plt.figure(figsize=(12, 6))
sns.scatterplot(data=pcaDf, x="PC1", y="PC2", hue="Molecule_type")

from sklearn.manifold import TSNE
tsne = TSNE(random_state = 19, n_components=2,verbose=0, 
            perplexity=10).fit_transform(X)

componentsDf = pd.DataFrame(data = tsne, columns = ['T1', 'T2'])
labelsol = pd.DataFrame(data = labelsol, columns = ['Labels'])
labeldata = pd.DataFrame(data = df, columns = ['Molecule_type'])
pcaDf = pd.concat([componentsDf, labelsol, labeldata], axis=1)
pcaDf['Labels'] = pcaDf['Labels'].apply(str)
pcaDf['Molecule_type'] = pcaDf['Molecule_type'].apply(str)


plt.figure(figsize=(12, 6))
sns.scatterplot(data=pcaDf, x="T1", y="T2", hue="Molecule_type")

import umap
reducer = umap.UMAP(random_state=42)
embedding = reducer.fit_transform(X)

componentsDf = pd.DataFrame(data = embedding, columns = ['U1', 'U2'])
labelsol = pd.DataFrame(data = labelsol, columns = ['Labels'])
labeldata = pd.DataFrame(data = df, columns = ['Molecule_type'])
pcaDf = pd.concat([componentsDf, labelsol, labeldata], axis=1)
pcaDf['Molecule_type'] = pcaDf['Molecule_type'].apply(str)


plt.figure(figsize=(12, 6))
sns.scatterplot(data=pcaDf, x="U1", y="U2", hue="Molecule_type")



# Spectral Clustering algorithm plus Silhouette Index
nclusters = 30
Nc = range(2, nclusters + 1)
from sklearn.metrics import silhouette_score
silhouette = np.zeros(nclusters-1)

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

K=14

clustersol = SpectralClustering(n_clusters=K, 
                              assign_labels='kmeans',
                              affinity='nearest_neighbors',
                              n_neighbors=3,
                              random_state=10)
labelsol = clustersol.fit_predict(X)
labelsol = labelsol + 1


from sklearn.decomposition import PCA
pca = PCA(n_components=2)
components = pca.fit_transform(X)

componentsDf = pd.DataFrame(data = components, columns = ['PC1', 'PC2'])
labelsol = pd.DataFrame(data = labelsol, columns = ['Labels'])
labeldata = pd.DataFrame(data = df, columns = ['Molecule_type'])
pcaDf = pd.concat([componentsDf, labelsol, labeldata], axis=1)
pcaDf['Labels'] = pcaDf['Labels'].apply(str)

# Complete para t-sne and umap