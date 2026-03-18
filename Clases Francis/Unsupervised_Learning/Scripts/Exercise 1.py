# Example Association Rules

#Clean environment and commmand line
from IPython import get_ipython
get_ipython().run_line_magic('reset','-f')
get_ipython().run_line_magic('clear','-f')

# Import modules
import os
import warnings
import pandas as pd

# Ignore warnings
warnings.filterwarnings("ignore")

#Fixed working directory
path = 'G:/Mi Unidad/Machine Learning/Classes/Clustering'
os.chdir(path)

# Read data
dataset = pd.read_csv('data/Market_Basket_Optimisation.csv', header = None) 
[n,p] = dataset.shape

transactions = []
for i in range(0, n):
    row = [str(dataset.values[i, j]) for j in range(p) if not pd.isna(dataset.values[i, j])]
    transactions.append(row)


print(transactions[2])


from apyori import apriori
rules = apriori(transactions, min_support = 5*7/n, min_confidence = 0.5,
                min_lift = 2, min_length = 2, max_length = 3)

results = list(rules)

results = pd.DataFrame(results)



# Fill analysis for Restaurant_New_York.csv

import pandas as pd

dataset1 = pd.read_csv('data/Restaurant_New_York.csv', header = None) 
[n, p]=dataset1.shape


