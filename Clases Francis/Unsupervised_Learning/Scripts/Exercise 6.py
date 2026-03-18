# Exercise 6 Clustering analysis

#Clean environment and commmand line
from IPython import get_ipython
get_ipython().run_line_magic('reset','-f')
get_ipython().run_line_magic('clear','-f')

# Import the modules
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.preprocessing import StandardScaler
from sklearn.manifold import TSNE
from sklearn.decomposition import PCA
from matplotlib import colors
import os
import warnings
from sklearn.cluster import KMeans, SpectralClustering
import seaborn as sns

# Ignore warnings
warnings.filterwarnings("ignore")

#Fixed working directory
path = 'G:/Mi unidad/Machine Learning/Classes/Clustering/data'
os.chdir(path)

# Impport data
train=  pd.read_csv('train.csv')

print(train.head())

Y = train.loc[:,'label'].values
X = train.loc[:,'pixel0':].values

# Plot some figures
plt.imshow(X[4].reshape(28, 28),
          cmap='binary', interpolation='nearest',
          clim=(0, 16))
plt.show()
# Standardize features by removing the mean and scaling to unit variance.
X = StandardScaler().fit_transform(X)

# Select a subset of images
p=10000
X = X[0:p]
Y= Y[0:p]

# All numbers are represented
print(np.unique(Y))

pca = PCA(n_components=2) 
components = pca.fit_transform(X)
pca_df = pd.DataFrame(data = components,
                            columns = ['PC1', 'PC2'])

plt.figure(figsize=(12, 6))
plt.scatter(data=pca_df, x="PC1", y="PC2", c=Y, cmap='Spectral')
plt.show()

# Visualize data with tSNE
tsne = TSNE(random_state = 42, n_components=2,verbose=0,
            perplexity=20).fit_transform(X)

plt.scatter(tsne[:, 0], tsne[:, 1], s= 5, c=Y, cmap='Spectral')
plt.title('Visualizing MNIST with t-SNE', fontsize=12);
plt.show()

# Visualize data with UMAP
import umap
reducer = umap.UMAP(random_state=42)
embedding = reducer.fit_transform(X)

plt.scatter(reducer.embedding_[:, 0],
            reducer.embedding_[:, 1], s= 5, c=Y, cmap='Spectral')
plt.title('Visualizing MNIST with UMAP', fontsize=12);



# Apply SOM
from sklearn_som.som import SOM
m=6
n=6
som = SOM(m=m, n=n, dim=X.shape[1])
som.fit(X, epochs=50)
predictions = som.predict(X)

# Plot the results
from statistics import mode
label_map = np.zeros(shape=(m,n),dtype=np.int64)
for row in range(m):
  for col in range(n):
    k = m*(row) + (col+1)
    label_list = predictions==k
    label_k = Y[label_list]
    if len(label_k)==0:
        label = 10;
    else:    
        label = mode(label_k)
    label_map[row][col] = label
    
colors1= ['green', 'red','orange',
          'blue','yellow','white',
          'black', 'purple','gold',
          'silver','skyblue']
cmap = colors.ListedColormap(colors1)
plt.imshow(label_map, cmap=cmap)
plt.gca().set_aspect('equal', 'datalim')
plt.colorbar(boundaries=np.arange(11)).set_ticks(np.arange(11))
plt.title('Visualizing MNIST with SOM', fontsize=12);
plt.show()


