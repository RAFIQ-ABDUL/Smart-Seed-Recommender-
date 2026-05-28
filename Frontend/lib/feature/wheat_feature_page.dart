import 'package:flutter/material.dart';
import '../api_service.dart';
import '../prediction_result_page.dart';

class WheatFeaturePage extends StatefulWidget {
  final VoidCallback onBack;

  const WheatFeaturePage({
    super.key,
    required this.onBack,
  });

  @override
  State<WheatFeaturePage> createState() => _WheatFeaturePageState();
}

class _WheatFeaturePageState extends State<WheatFeaturePage> {
  final _formKey = GlobalKey<FormState>();

  String? soilType;
  String? region;
  String? irrigationSource;
  String? sown;
  String soilPh = "";
  String temp = "";

  bool isLoading = false;
  final List<String> soilTypes = ["loamy", "clay loam", "sandy loam", "silt loam"];
  final List<String> regions = ["Punjab North", "Potohar", "Canal Area", "South Punjab", "Central Punjab"];
  final List<String> irrigationSources = ["canal", "tube well", "mixed", "rainfed"];
  final List<String> sownMonths = ["Oct", "Nov", "Dec"];

  void handlePrediction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> wheatPayload = {
        'soil_type': soilType,
        'region': region,
        'irrigation_source': irrigationSource,
        'sown': sown,
        'soil_ph': double.parse(soilPh),
        'temp': double.parse(temp),
      };

      try {
        String result = await ApiService.fetchSeedRecommendation(
          cropType: 'wheat',
          payload: wheatPayload,
        );

        setState(() {
          isLoading = false;
        });

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PredictionResultPage(
                cropType: 'Wheat',
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
        title: const Text("Wheat Seed Prediction"),
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
              _dropdown(label: "Region / Zone", items: regions, value: region, onChanged: (v) => setState(() => region = v)),
              _dropdown(label: "Irrigation Source", items: irrigationSources, value: irrigationSource, onChanged: (v) => setState(() => irrigationSource = v)),
              _dropdown(label: "Sown Month", items: sownMonths, value: sown, onChanged: (v) => setState(() => sown = v)),
              _numericInput(label: "Soil pH Level", placeholder: "e.g., 6.5", onChanged: (v) => setState(() => soilPh = v)),
              _numericInput(label: "Average Temperature (°C)", placeholder: "e.g., 22.5", onChanged: (v) => setState(() => temp = v)),
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
          if (double.tryParse(value) == null) return "Please enter a valid numeric decimal";
          return null;
        },
      ),
    );
  }
}