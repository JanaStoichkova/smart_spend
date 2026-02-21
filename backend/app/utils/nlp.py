# backend/utils/nlp.py
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.feature_extraction.text import TfidfVectorizer
import pickle
import re
import os

# Try to import NLTK, fallback to basic if not available
try:
    from nltk.corpus import stopwords
    from nltk.stem import WordNetLemmatizer
    NLTK_AVAILABLE = True
except ImportError:
    NLTK_AVAILABLE = False
def load_data(csv_path: str):
    df = pd.read_csv(csv_path)
    return df


def preprocess_text(df):
    def clean_text(text):
        # Convert to lowercase
        text = text.lower()
        # Remove special characters and numbers
        text = re.sub(r'[^a-zA-Z\s]', '', text)
        
        if NLTK_AVAILABLE:
            # Use NLTK if available
            lemmatizer = WordNetLemmatizer()
            stop_words = set(stopwords.words('english'))
            words = text.split()
            words = [lemmatizer.lemmatize(word) for word in words if word not in stop_words and len(word) > 2]
            return ' '.join(words)
        else:
            # Basic preprocessing without NLTK
            # Remove basic stopwords manually
            basic_stopwords = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should'}
            words = text.split()
            words = [word for word in words if word not in basic_stopwords and len(word) > 2]
            return ' '.join(words)
    
    df['description'] = df['description'].apply(clean_text)
    return df

def split_data(df: pd.DataFrame):
    X = df['description']
    y = df['category']

    # Encode categories as numbers
    le = LabelEncoder()
    y_encoded = le.fit_transform(y)

    # Split into train and test (stratified for better distribution)
    X_train, X_test, y_train, y_test = train_test_split(X, y_encoded, test_size=0.2, random_state=42, stratify=y_encoded)
    return X_train, X_test, y_train, y_test, le

def vectorize_text(X_train, X_test):
    vectorizer = TfidfVectorizer(
        ngram_range=(1, 2),  # unigrams, bigrams
        max_features=1000,
        min_df=1,
        max_df=0.8,
        sublinear_tf=True,
        analyzer='word'
    )
    X_train_vec = vectorizer.fit_transform(X_train)
    X_test_vec = vectorizer.transform(X_test)
    return X_train_vec, X_test_vec, vectorizer


# Load saved model, vectorizer, and label encoder

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

with open(os.path.join(BASE_DIR, "expense_model.pkl"), "rb") as f:
    model = pickle.load(f)

with open(os.path.join(BASE_DIR, "tfidf_vectorizer.pkl"), "rb") as f:
    vectorizer = pickle.load(f)

with open(os.path.join(BASE_DIR, "label_encoder.pkl"), "rb") as f:
    label_encoder = pickle.load(f)


def predict_category(description: str) -> str:
    """
    Predict the category of a single expense description
    """
    desc_vec = vectorizer.transform([description.lower()])
    pred_encoded = model.predict(desc_vec)[0]
    category = label_encoder.inverse_transform([pred_encoded])[0]
    return category