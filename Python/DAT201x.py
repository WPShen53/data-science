# -*- coding: utf-8 -*-
"""
Created on Sat Jul 09 14:57:41 2016

@author: Wenping Shen
"""
###
### Manipulating Data
###

import pandas as pd

df = pd.read_csv('tutorial.csv')
print df

from sqlalchemy import create_engine
engine = create_engine('sqlite:///:memory:')

sql_dataframe  = pd.read_sql_table('my_table', engine, columns=['ColA', 'ColB'])
xls_dataframe  = pd.read_excel('my_dataset.xlsx', 'Sheet1', na_values=['NA', '?'])
json_dataframe = pd.read_json('my_dataset.json', orient='columns')
csv_dataframe  = pd.read_csv('my_dataset.csv', sep=',')
table_dataframe= pd.read_html('http://page.com/with/table.html', names=['col0', 'col1', 'col2'])[0]

df.to_sql('table', engine)
df.to_excel('dataset.xlsx')
df.to_json('dataset.json')
df.to_csv('dataset.csv')

df.columns
df.index
df.head(2)
df.tail(5)
df.describe()

df.col0
df['col0']
df[['col0']]
df.loc[:, 'col0']
df.loc[:, ['col0']]
df.iloc[:, 0]
df.iloc[:, [0]]
df.ix[:, 0]

df.col0 < 0
df[df.col0 <0]
df[(df.col0<0)|(df.col1<0)]


###
### Feature Representation
###

ordered_satisfaction = ['Very Unhappy', 'Unhappy', 'Neutral', 'Happy', 'Very Happy']
df = pd.DataFrame({'satisfaction':['Mad', 'Happy', 'Unhappy', 'Neutral']})
df.satisfaction = df.satisfaction.astype("category",
  ordered=True,
  categories=ordered_satisfaction
).cat.codes
print df

df = pd.DataFrame({'vertebrates':['Bird','Bird','Mammal','Fish','Amphibian','Reptile','Mammal',]})
# df['vertebrates'] = df.vertebrates.astype("category").cat.codes #Method 1
df = pd.get_dummies(df,columns=['vertebrates']) #Method 2
print df

from sklearn.feature_extraction.text import CountVectorizer
corpus = [
  "Authman ran faster than Harry because he is an athlete.",
  "Authman and Harry ran faster and faster.",
]
bow = CountVectorizer()
X = bow.fit_transform(corpus) # Sparse Matrix
print bow.get_feature_names()
print X.toarray()

# Uses the Image module (PIL)
from scipy import misc

# Load the image up
img = misc.imread('Course Golden Ratio.png')
print type(img)
print img.shape, img.dtype

# gray scale img
red = img[:,0]
green = img[:,1]
blue = img[:,2]
gray = (0.299*red + 0.587*green + 0.114*blue)

# Is the image too big? Shrink it by an order of magnitude
img = img[::2, ::2]

# Scale colors from (0-255) to (0-1), then reshape to 1D Array
X = (img / 255.0).reshape(-1, 3)

# For audio
import scipy.io.wavfile as wavfile
sample_rate, audio_data = wavfile.read('sound.wav')
print audio_data


###
### Wrangling Data
###

df.vertebrates_Bird.isnull()
df.notnull()

df.vertebrates_Bird.fillna( df.my_feature.mean() )
df.fillna(0)
df.fillna(method='ffill')  # fill the values forward
df.fillna(method='bfill')  # fill the values in reverse
df.fillna(limit=5)

df = df.dropna(axis=0)  # row 
df = df.dropna(axis=1)  # column

# Drop any row that has at least 4 NON-NaNs within it:
df = df.dropna(axis=0, thresh=4)

# Axis=1 for columns
df = df.drop(labels=['Features', 'To', 'Delete'], axis=1)
df = df.drop_duplicates(subset=['Feature_1', 'Feature_2'])
# reindex after dropping the duplicates
df = df.reset_index(drop=True) # drop=True remove the backup copy of original index
# chain the above togather
df = df.dropna(axis=0, thresh=2).drop(labels=['ColA'], axis=1)\
     .drop_duplicates(subset=['ColB', 'ColC']).reset_index()

print df.types
df.Date = pd.to_datetime(df.Date, errors='coerce')
df.Height = pd.to_numeric(df.Height, errors='coerce')
df.Weight = pd.to_numeric(df.Weight, errors='coerce')
df.Age = pd.to_numeric(df.Age, errors='coerce')
print df.dtypes

df.vertebrates_Bird.unique()
df.vertebrates_Bird.value_counts()
