from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import joblib
import pandas as pd
import numpy as np
import os
from catboost import CatBoostClassifier
 

app = FastAPI(
    title="Smart Seed Recommender System API",
    description="Backend API optimizing seed selection for the Pakistani market using CatBoost.",
    version="1.1.0"
)

# Enable CORS for Flutter Web testing
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allows requests from any local Flutter web port
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global memory caches for ML components
MODELS = {}
ENCODERS = {}
CROPS = ["cotton", "wheat", "rice", "maize"]

@app.on_event("startup")
def load_ml_components():
    """Loads all CatBoost models and Scikit-Learn LabelEncoders sequentially into RAM on startup."""
    model_dir = "models"
    for crop in CROPS:
        model_path = os.path.join(model_dir, f"{crop}_seed_model.pkl")
        encoder_path = os.path.join(model_dir, f"{crop}_seed_label_encoder.pkl")
        
        if os.path.exists(model_path) and os.path.exists(encoder_path):
            try:
                MODELS[crop] = joblib.load(model_path)
                ENCODERS[crop] = joblib.load(encoder_path)
                print(f"Successfully loaded model and encoder for: {crop}")
            except Exception as e:
                print(f"Fatal error loading components for {crop}: {e}")
        else:
            print(f"CRITICAL CRASH WARNING: Missing files for {crop} inside '{model_dir}/'")

# --- STRICT SCHEMA DECLARATIONS ---
# Every parameter is explicitly typed and mandatory. No default parameters or optionals.

class CottonPredictionRequest(BaseModel):
    soil_type: str
    water_source: str
    soil_ph: float
    temperature: float
    nitrogen_N: float
    phosphorus_P: float
    potassium_K: float

class WheatPredictionRequest(BaseModel):
    soil_type: str
    region: str
    irrigation_source: str
    sown: str
    soil_ph: float
    temp: float

class RicePredictionRequest(BaseModel):
    soil_type: str
    water_source: str
    soil_ph: float
    temperature: float
    nitrogen_N: float
    phosphorus_P: float
    potassium_K: float

class MaizePredictionRequest(BaseModel):
    soil_type: str
    water_source: str
    soil_ph: float
    temperature: float
    nitrogen_N: float
    phosphorus_P: float
    potassium_K: float


@app.get("/")
def health_check():
    return {"status": "online", "message": "Smart Seed Recommender API is fully functional."}


# --- ENDPOINTS PER CROP TYPE ---
# Explicit endpoints ensure precise parameter mapping and validation boundaries.

@app.post("/predict/cotton")
def predict_cotton(payload: CottonPredictionRequest):
    if "cotton" not in MODELS:
        raise HTTPException(status_code=503, detail="Cotton model not initialized on server.")
    try:
        data_dict = {
            'soil_type': [str(payload.soil_type)],
            'water_source': [str(payload.water_source)],
            'soil_ph': [float(payload.soil_ph)],
            'temperature': [float(payload.temperature)],
            'nitrogen_N': [float(payload.nitrogen_N)],
            'phosphorus_P': [float(payload.phosphorus_P)],
            'potassium_K': [float(payload.potassium_K)]
        }
        return process_prediction("cotton", data_dict)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Cotton prediction failed: {str(e)}")


@app.post("/predict/wheat")
def predict_wheat(payload: WheatPredictionRequest):
    if "wheat" not in MODELS:
        raise HTTPException(status_code=503, detail="Wheat model not initialized on server.")
    try:
        data_dict = {
            'soil_type': [str(payload.soil_type)],
            'region': [str(payload.region)],
            'irrigation_source': [str(payload.irrigation_source)],
            'sown': [str(payload.sown)],
            'soil_ph': [float(payload.soil_ph)],
            'temp': [float(payload.temp)]
        }
        return process_prediction("wheat", data_dict)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Wheat prediction failed: {str(e)}")


@app.post("/predict/rice")
def predict_rice(payload: RicePredictionRequest):
    if "rice" not in MODELS:
        raise HTTPException(status_code=503, detail="Rice model not initialized on server.")
    try:
        data_dict = {
            'soil_type': [str(payload.soil_type)],
            'water_source': [str(payload.water_source)],
            'soil_ph': [float(payload.soil_ph)],
            'temperature': [float(payload.temperature)],
            'nitrogen_N': [float(payload.nitrogen_N)],
            'phosphorus_P': [float(payload.phosphorus_P)],
            'potassium_K': [float(payload.potassium_K)]
        }
        return process_prediction("rice", data_dict)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Rice prediction failed: {str(e)}")


@app.post("/predict/maize")
def predict_maize(payload: MaizePredictionRequest):
    if "maize" not in MODELS:
        raise HTTPException(status_code=503, detail="Maize model not initialized on server.")
    try:
        data_dict = {
            'soil_type': [str(payload.soil_type)],
            'water_source': [str(payload.water_source)],
            'soil_ph': [float(payload.soil_ph)],
            'temperature': [float(payload.temperature)],
            'nitrogen_N': [float(payload.nitrogen_N)],
            'phosphorus_P': [float(payload.phosphorus_P)],
            'potassium_K': [float(payload.potassium_K)]
        }
        return process_prediction("maize", data_dict)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Maize prediction failed: {str(e)}")


def process_prediction(crop_type: str, data: dict) -> dict:
    """Helper method to handle pandas conversion, CatBoost inference, and inverse transform decoding."""
    # Convert input to DataFrame to explicitly enforce feature column names
    df_features = pd.DataFrame(data)
    
    model = MODELS[crop_type]
    encoder = ENCODERS[crop_type]
    
    # Generate prediction from CatBoost
    raw_prediction = model.predict(df_features)
    
    # Safely extract scalar value from array wrappers
    predicted_index = int(np.ravel(raw_prediction)[0])
    
    # Safely inverse transform encoded numerical back into original Pakistani market string label
    seed_variety = encoder.inverse_transform([predicted_index])[0]
    
    return {
        "status": "success",
        "crop_type": crop_type,
        "seed_variety": str(seed_variety)
    }