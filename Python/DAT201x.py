# -*- coding: utf-8 -*-
"""
Created on Sat Jul 09 14:57:41 2016

@author: Wenping Shen
"""

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

import scipy.io.wavfile as wavfile
sample_rate, audio_data = wavfile.read('sound.wav')
print audio_data
