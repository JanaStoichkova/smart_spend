# SmartSpend

An AI-powered expense tracking application that uses machine learning to automatically categorize your expenses.

## Features

### Core Features
- AI-Powered Categorization - Machine learning automatically categorizes expenses based on description
- Monthly Summaries - Track spending by category with beautiful charts
- Expense Management - Add, view, and edit expenses easily
- User Authentication - Secure login/signup system
- Beautiful Modern UI - Clean, intuitive interface

### Technical Highlights
- 75.8% ML Accuracy - Trained on custom expense dataset
- FastAPI Backend - High-performance Python API
- Flutter Frontend - Cross-platform mobile/web app
- SQLite Database - Local data storage
- CORS Enabled - Easy frontend integration

---

## Screenshots

### 1. Login Screen
```
+-----------------------------+
|     SmartSpend             |
|   Track expenses with AI   |
|                           |
|  +-----------------------+ |
|  | Username               | |
|  +-----------------------+ |
|                           |
|  +-----------------------+ |
|  | Password               | |
|  +-----------------------+ |
|                           |
|  [       Login          ] |
|                           |
|  Create an account         |
+-----------------------------+
```

### 2. Add Expense Screen
```
+-----------------------------+
|  Add Expense               |
|  AI will auto-categorize  |
|                           |
|  +-----------------------+ |
|  | $ 0.00                | |
|  +-----------------------+ |
|                           |
|  +-----------------------+ |
|  | What did you spend on? | |
|  | Lunch at Italian...   | |
|  +-----------------------+ |
|                           |
|  [  Add with AI  ]        |
|                           |
|  +-----------------------+ |
|  | Expense added!         | |
|  | Category: FOOD        | |
|  +-----------------------+ |
|                           |
|  Quick Add: $5 $10 $20    |
+-----------------------------+
```

### 3. Monthly Summary Screen
```
+-----------------------------+
|  Monthly Summary            |
|                           |
|  [Month] [Year]          |
|                           |
|  +-----------------------+ |
|  |    Total Spent        | |
|  |     $1,234.56        | |
|  |    January 2026       | |
|  +-----------------------+ |
|                           |
|  By Category               |
|                           |
|  Food        $450.00     |
|  36%                      |
|                           |
|  Transportation $200.00   |
|  16%                      |
|                           |
|  Entertainment $150.00    |
|  12%                      |
+-----------------------------+
```

### 4. Expense List Screen
```
+-----------------------------+
|  All Expenses              |
|                           |
|  +-----------------------+ |
|  | Lunch at Italian     | |
|  | Food         $25.00  | |
|  +-----------------------+ |
|                           |
|  +-----------------------+ |
|  | Uber to Airport       | |
|  | Transportation $45.00 | |
|  +-----------------------+ |
|                           |
|  +-----------------------+ |
|  | Netflix               | |
|  | Entertainment $15.00 | |
|  +-----------------------+ |
|                           |
|  (Tap to edit category)    |
+-----------------------------+
```

---

## Getting Started

### Prerequisites

- Python 3.9+
- Flutter SDK 3.0+
- Node.js (optional, for web serving)

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Train the ML model:
```bash
python -m app.utils.train_model
```

4. Start the backend server:
```bash
python -m uvicorn app.main:app --reload
```

The API will be available at http://127.0.0.1:8000

### Frontend Setup

1. Navigate to frontend directory:
```bash
cd smartspend_frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# Web (recommended)
flutter run -d chrome

# Mobile
flutter run

# Desktop
flutter run -d windows
```

---

## Project Structure

```
SmartSpend/
+-- backend/
|   +-- app/
|   |   +-- main.py              # FastAPI app entry point
|   |   +-- models.py            # SQLAlchemy models
|   |   +-- schemas.py            # Pydantic schemas
|   |   +-- database.py           # Database configuration
|   |   +-- routes/
|   |   |   +-- auth.py          # Login/Signup endpoints
|   |   |   +-- expenses.py      # CRUD expenses
|   |   |   +-- categories.py    # Categories endpoint
|   |   |   +-- predict.py       # ML prediction endpoint
|   |   +-- utils/
|   |       +-- nlp.py           # ML preprocessing
|   |       +-- train_model.py   # Model training
|   |       +-- security.py      # Password hashing
|   +-- expenses_dataset.csv     # Training data
|   +-- requirements.txt         # Python dependencies
|   +-- smartspend.db           # SQLite database
|
+-- smartspend_frontend/
|   +-- lib/
|   |   +-- main.dart           # Flutter app
|   +-- pubspec.yaml            # Flutter dependencies
|   +-- build/                  # Compiled web app
|
+-- README.md
```

---

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| /auth/signup | POST | Create new account |
| /auth/login | POST | Login and get token |
| /expenses/ | GET | List all expenses |
| /expenses/ | POST | Add new expense |
| /expenses/{id} | PUT | Update expense |
| /expenses/{id} | DELETE | Delete expense |
| /expenses/summary/{year}/{month} | GET | Monthly summary |
| /ml/predict | POST | Predict category |

---

## Machine Learning

### Model Details
- Algorithm: SVM (Linear Kernel)
- Features: TF-IDF with n-grams (1-2)
- Accuracy: 75.8%
- Training Data: Custom expense dataset

### Categories
- Food
- Transportation
- Entertainment
- Shopping
- Utilities
- Health
- Education
- Housing
- Personal Care

### Training Data Format
```csv
description,category
coffee at starbucks,Food
uber ride,Transportation
netflix subscription,Entertainment
```

---

## UI/UX Features

### Design System
- Primary Color: Indigo (#6366F1)
- Secondary Colors: Purple, Pink gradients
- Typography: System fonts
- Cards: Rounded corners with subtle shadows

### Components
- Gradient backgrounds
- Glassmorphism cards
- Progress bars for categories
- Quick-add amount buttons
- Pull-to-refresh lists
- Editable categories with dialogs

---

## Configuration

### Change API URL

In smartspend_frontend/lib/main.dart:

```dart
static const String _baseUrl = 'http://YOUR_IP:8000';
```

### Change Database

In backend/app/database.py:

```python
DATABASE_URL = "sqlite:///./your_database.db"
```

---

## Performance

| Metric | Value |
|--------|-------|
| ML Accuracy | 75.8% |
| API Response Time | <100ms |
| Frontend Build Size | ~2MB |
| Cold Start Time | <2s |

---

## Tech Stack

### Backend
- FastAPI - Modern Python web framework
- SQLAlchemy - ORM for database
- Python-JOSE - JWT authentication
- scikit-learn - Machine learning
- NLTK - Natural language processing

### Frontend
- Flutter - Cross-platform UI framework
- Material Design 3 - Modern design system
- http - HTTP client

### Database
- SQLite - Local relational database

---

## Contributing

1. Fork the repository
2. Create a feature branch (git checkout -b feature/amazing)
3. Commit your changes (git commit -m 'Add amazing feature')
4. Push to the branch (git push origin feature/amazing)
5. Open a Pull Request

---

## License

MIT License - feel free to use this project for learning or commercial purposes.

---

Made with love using Python + Flutter
