# Smart Seed Recommender 🌾

A decoupled, high-performance, full-stack machine learning application designed to optimize crop yield in Pakistan by predicting the most suitable seed varieties based on localized soil and environmental parameters. The system currently supports four primary target cash crops: **Wheat, Maize, Rice, and Cotton**.

---

## System Architecture & Overview

The platform uses a decoupled multi-tier architectural design pattern split into an agile mobile presentation layer and a high-performance machine learning inference model:

1. **Presentation Tier (Mobile Client - Flutter):** Built using the Flutter cross-platform framework to run natively across Android and web. It manages user dashboard transitions, client-side input validation boundaries, and embeds zero-latency local JSON storage files for agronomic cultivation schedules and market pricing indexes.
2. **Application & Inference Tier (Server - FastAPI):** A fast, asynchronous Python backend optimized via the `uv` dependency manager. It features dedicated REST API routing controllers that accept structured JSON feature data arrays and pass them through a data preprocessing pipeline.
3. **Machine Learning Layer (CatBoost Engine):** Serialized Gradient Boosting model artifacts (`.pkl` format) trained specifically for targeted crop matrices. It returns calculated variety predictive string tokens back down through the HTTP connection loop to the client app.

---

## Tech Stack & Key Tooling

- **Frontend Client:** Flutter, Dart, Shared Preferences (Local state cache)
- **Backend API Server:** Python 3.11+, FastAPI, Pydantic (Data validation rules), Uvicorn
- **Dependency & Environment Manager:** `uv` (Astral's ultra-fast Python package compiler)
- **Machine Learning Lifecycle:** CatBoost, Scikit-Learn, NumPy, Pickle

---

## System Features & Functional Map

- **Target Crop Selection:** Dedicated parameter entry configurations tailored dynamically for Wheat, Maize, Rice, or Cotton.
- **Client-Side Form Guarding:** Localized validation checks that actively intercept empty text inputs or out-of-bounds soil characteristics (e.g., pH scales outside $0.0 - 14.0$).
- **Asynchronous ML Inference Loop:** Automated API processing utilizing trained CatBoost models to yield precise seed selections based on Macronutrients ($N, P, K$), Temperature, and Regional Soil properties.
- **Data Binding & Local Enrichment:** Real-time pairing of predictive string outputs with localized market price ranges, expected acre yield targets, and alternative varieties.
- **Production Management Schedule:** Chronological agronomic workflows and expert field guidelines displayed via dynamic interactive widgets to aid outdoor execution.
