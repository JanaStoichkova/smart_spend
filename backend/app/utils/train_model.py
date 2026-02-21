# backend/utils/train_model.py
from sklearn.svm import SVC
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.metrics import accuracy_score
from sklearn.model_selection import GridSearchCV
import pickle
from .nlp import load_data, preprocess_text, split_data, vectorize_text

CSV_PATH = "expenses_dataset.csv"  # Use full dataset
MODEL_PATH = "expense_model.pkl"
VECTORIZER_PATH = "tfidf_vectorizer.pkl"
LABEL_ENCODER_PATH = "label_encoder.pkl"

# Load and preprocess data
df = load_data(CSV_PATH)
df = preprocess_text(df)

# Split data
X_train, X_test, y_train, y_test, le = split_data(df)

# Vectorize
X_train_vec, X_test_vec, vectorizer = vectorize_text(X_train, X_test)

# Try multiple models and choose the best
models = {
    'SVM': SVC(kernel='linear', C=1.0, random_state=42, class_weight='balanced'),
    'SVM_RBF': SVC(kernel='rbf', C=10.0, random_state=42, class_weight='balanced'),
    'GradientBoosting': GradientBoostingClassifier(n_estimators=100, random_state=42)
}

best_model = None
best_score = 0
best_name = ""

for name, model in models.items():
    model.fit(X_train_vec, y_train)
    y_pred = model.predict(X_test_vec)
    score = accuracy_score(y_test, y_pred)
    print(f"{name} Accuracy: {score:.3f}")
    
    if score > best_score:
        best_score = score
        best_model = model
        best_name = name

print(f"\nBest model: {best_name} with accuracy: {best_score:.3f}")
model = best_model

# Test accuracy
y_pred = model.predict(X_test_vec)
print("Test Accuracy:", accuracy_score(y_test, y_pred))

# Save model and preprocessors
with open(MODEL_PATH, "wb") as f:
    pickle.dump(model, f)

with open(VECTORIZER_PATH, "wb") as f:
    pickle.dump(vectorizer, f)

with open(LABEL_ENCODER_PATH, "wb") as f:
    pickle.dump(le, f)
