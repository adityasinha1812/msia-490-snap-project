import pandas as pd
import datetime
import dateutil.parser
import inflect
import re
import unicodedata
import nltk
from nltk import WordNetLemmatizer
from nltk.corpus import stopwords
from nltk.sentiment.vader import SentimentIntensityAnalyzer 
from nltk.stem.lancaster import LancasterStemmer

class TextProcessing:
    '''Basic text processing
    Parameters
    ----------
    words: str
        text to be processed
    Return
    ----------
    words: str
        processed text
    '''

    def __init__(self):
        pass

    def remove_html(self, words):
        '''Remove message with html'''
        return re.sub(r'^<p.*</p>', '', words)

    def remove_URL(self, sample):
        """Remove URLs from a sample string"""
        return re.sub(r"http\S+", "", sample)

    def remove_non_ascii(self, words):
        """Remove non-ASCII characters from list of tokenized words"""
        return [unicodedata.normalize('NFKD', word).encode('ascii', 'ignore').decode('utf-8', 'ignore') for word in words]

    def to_lowercase(self, words):
        """Convert all characters to lowercase from list of tokenized words"""
        return [word.lower() for word in words]

    def remove_punctuation(self, words):
        """Remove punctuation from list of tokenized words"""
        return [re.sub(r'[^\w\s]', '', word) for word in words]

    def replace_numbers(self, words):
        """Replace all interger occurrences in list of tokenized words with textual representation"""
        p = inflect.engine()
        return [p.number_to_words(word) if word.isdigit() else word for word in words]

    def remove_stopwords(self, words):
        """Remove stop words from list of tokenized words"""
        return [word for word in words if word not in stopwords.words('english')]

    def stem_words(self, words):
        """Stem words in list of tokenized words"""
        stemmer = LancasterStemmer()
        return [stemmer.stem(word) for word in words]

    def lemmatize_verbs(self, words):
        """Lemmatize verbs in list of tokenized words"""
        lemmatizer = WordNetLemmatizer()
        return [lemmatizer.lemmatize(word, pos='v') for word in words]

    def normalize(self, words):
        words = self.remove_non_ascii(words)
        words = self.to_lowercase(words)
        words = self.remove_punctuation(words)
        words = self.replace_numbers(words)
        words = self.remove_stopwords(words)
        # Remove space
        words = ' '.join(words).replace('  ', ' ').strip().split(' ')
        try:
            words.remove('')
        except:
            pass

        return words

    def preprocess(self, sample):
        sample = self.remove_html(sample)
        sample = self.remove_URL(sample)
        # Tokenize
        words = nltk.word_tokenize(sample)

        # Normalize
        words = self.normalize(words)
        # return sample
        return ' '.join(words)

def predict_sentiment(sentence):
    '''Predict sentiment and the confidentality of the predicted sentiment'''
    
    sid = SentimentIntensityAnalyzer()
    sentiment_dict = sid.polarity_scores(sentence)
    
    # decide sentiment as positive, negative and neutral 
    if sentiment_dict['compound'] >= 0.05 : 
        return ("Positive", round(sentiment_dict['pos']*100, 2))
  
    elif sentiment_dict['compound'] <= - 0.05 : 
        return ("Negative", round(sentiment_dict['neg']*100, 2))
  
    else : 
        return ("Neutral", round(sentiment_dict['neu']*100, 2))


messages_all = pd.read_csv('C:/Users/adity/Downloads/SNA/SNAP/msia-490-snap-project/data/aditya_messages.csv')
messages_all['DATE'] = messages_all['DATE'].map(lambda x: dateutil.parser.parse(x).date())

split_date = datetime.date(2020, 3, 31)
messages_pre = messages_all[(messages_all['DATE'] <= split_date)]
messages_post = messages_all[(messages_all['DATE'] > split_date)]

messages_content_pre = messages_pre.CONTENT
messages_content_post = messages_post.CONTENT
      
preprocessor = TextProcessing()

messages_content_pre = messages_content_pre.map(lambda x: re.sub("[^a-zA-Z]", " ", str(x)))
messages_content_post = messages_content_post.map(lambda x: re.sub("[^a-zA-Z]", " ", str(x)))

processed_pre = [preprocessor.preprocess(message) for message in messages_content_pre]
processed_post = [preprocessor.preprocess(message) for message in messages_content_post]

# Remove empty string
while("" in processed_pre):
    processed_pre.remove("")

# Remove empty string
while("" in processed_post):
    processed_post.remove("")
    
sentiment_pre = [predict_sentiment(message) for message in processed_pre]
sentiment_post = [predict_sentiment(message) for message in processed_post]

sentiment_df_pre = pd.concat([pd.DataFrame(processed_pre, columns = ['Message']), pd.DataFrame(sentiment_pre, columns = ['Sentiment', 'Confident'])], axis = 1)
sentiment_df_post = pd.concat([pd.DataFrame(processed_post, columns = ['Message']), pd.DataFrame(sentiment_post, columns = ['Sentiment', 'Confident'])], axis = 1)

sentiment_df_pre['Sentiment'].value_counts().plot.bar()
sentiment_df_post['Sentiment'].value_counts().plot.bar()
