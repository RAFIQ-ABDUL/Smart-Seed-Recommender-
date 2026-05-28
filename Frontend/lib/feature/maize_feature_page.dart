import 'package:flutter/material.dart';
import '../api_service.dart';
import '../prediction_result_page.dart';

class MaizeFeaturePage extends StatefulWidget {
  final VoidCallback onBack;

  const MaizeFeaturePage({
    super.key,
    required this.onBack,
  });

  @override
  State<MaizeFeaturePage> createState() => _MaizeFeaturePageState();
}

class _MaizeFeaturePageState extends State<MaizeFeaturePage> {
  final _formKey = GlobalKey<FormState>();

  String? soilType;
  String? waterSource;
  String soilPh = "";
  String temperature = "";
  String nitrogenN = "";
  String phosphorusP = "";
  String potassiumK = "";

  bool isLoading = false;
  final List<String> soilTypes = ["Sandy Loam", "Loamy soil", "Clay Loam"];
  final List<String> waterSources = ["irrigated", "rainfed"];

  void handlePrediction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> maizePayload = {
        'crop_type': 'maize',
        'soil_type': soilType,
        'water_source': waterSource,
        'soil_ph': double.parse(soilPh),
        'temperature': double.parse(temperature),
        'nitrogen_N': double.parse(nitrogenN),
        'phosphorus_P': double.parse(phosphorusP),
        'potassium_K': double.parse(potassiumK),
      };

      try {
        String result = await ApiService.fetchSeedRecommendation(
          cropType: 'maize',
          payload: maizePayload,
        );

        setState(() {
          isLoading = false;
        });

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PredictionResultPage(
                cropType: 'Maize',
                predictedSeed: result,
              ),
            ),
          );
        }
      } catch (error) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maize Seed Prediction"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dropdown(label: "Soil Type", items: soilTypes, value: soilType, onChanged: (v) => setState(() => soilType = v)),
              _dropdown(label: "Water Source", items: waterSources, value: waterSource, onChanged: (v) => setState(() => waterSource = v)),
              _numericInput(label: "Soil pH Level", placeholder: "e.g., 6.5", onChanged: (v) => setState(() => soilPh = v)),
              _numericInput(label: "Temperature (°C)", placeholder: "e.g., 28.0", onChanged: (v) => setState(() => temperature = v)),
              _numericInput(label: "Nitrogen (N) value", placeholder: "e.g., 120.0", onChanged: (v) => setState(() => nitrogenN = v)),
              _numericInput(label: "Phosphorus (P) value", placeholder: "e.g., 50.0", onChanged: (v) => setState(() => phosphorusP = v)),
              _numericInput(label: "Potassium (K) value", placeholder: "e.g., 60.0", onChanged: (v) => setState(() => potassiumK = v)),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : ElevatedButton(
                onPressed: handlePrediction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Predict Best Seed Variety", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown({required String label, required List<String> items, required String? value, required Function(String?) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "$label selection is required" : null,
      ),
    );
  }

  Widget _numericInput({required String label, required String placeholder, required Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return "$label input is required";
          if (double.tryParse(value) == null) return "Please enter a valid decimal number";
          return null;
        },
      ),
    );
  }
}