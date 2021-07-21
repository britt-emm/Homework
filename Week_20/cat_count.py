#!/usr/bin/env python3

import sys

import nltk

from nltk.tokenize import word_tokenize
from collections import Counter

sw = set(nltk.corpus.stopwords.words('english'))
# open the file
with open('cats_txt.txt', 'r') as cats:
    cat_lines = cats.read()
    #print(cat_lines)
    
    # tokenize text
    cat_block = [w for w in word_tokenize(cat_lines.lower())]
    # get rid of stop words
    no_stops = [word for word in cat_block if word not in sw]
    
    # count words, list most common
    print(Counter(no_stops).most_common(10))

    #Count and tokenize all words including stop words 
    print(Counter(word_tokenize(cat_lines.lower())).most_common())
    
    

