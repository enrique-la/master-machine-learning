# Exercise 4 Clustering analysis

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

# Hierarchial Clustering

from scipy.cluster.hierarchy import dendrogram, linkage
linkage_data = linkage(X, method='average', metric='euclidean')
names = df["Molecule_type"]
names = names.astype(str).tolist()
dendrogram(linkage_data, labels=names)
plt.show()

# K-means algorithm plus Elbow

nclusters = 30
Nc = range(1, nclusters + 1)
score = np.zeros(nclusters)

for i in Nc:
    
    cluster1 = KMeans(n_clusters=i, n_init="auto", random_state=20)
    labels = cluster1.fit_predict(X)
    score[i-1] = -cluster1.fit(X).score(X)

score = np.asarray(score)

plt.plot(Nc,score)
plt.xlabel('Number of Clusters')
plt.ylabel('Score')
x = np.linspace(2,nclusters,nclusters-1)
plt.xticks(x)
plt.title('Elbow Curve')
plt.show()

K=9

clustersol = KMeans(n_clusters=K, n_init="auto", random_state=20)
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

pcaDf['Majority_Label'] = (
    pcaDf.groupby('Labels')['Molecule_type']
      .transform(lambda x: x.mode().iat[0])
)


plt.figure(figsize=(12, 6))
sns.scatterplot(data=pcaDf, x="PC1", y="PC2", hue="Majority_Label")

matches = (pcaDf['Majority_Label'] == df['Molecule_type']).sum()
print(matches)


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


K=13

clustersol = KMeans(n_clusters=K, n_init="auto", random_state=20)
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

pcaDf['Majority_Label'] = (
    pcaDf.groupby('Labels')['Molecule_type']
      .transform(lambda x: x.mode().iat[0])
)


plt.figure(figsize=(12, 6))
sns.scatterplot(data=pcaDf, x="PC1", y="PC2", hue="Majority_Label")

matches = (pcaDf['Majority_Label'] == df['Molecule_type']).sum()
print(matches)

# Spectral Clustering algorithm plus Silhouette Index

# Complete here