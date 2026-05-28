import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductionManagementPage extends StatelessWidget {
  final String cropType;

  const ProductionManagementPage({super.key, required this.cropType});

  Future<Map<String, dynamic>?> _loadCropData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/crop_data.json');
      final data = json.decode(response);
      final List crops = data['crops'];
      return crops.firstWhere(
            (crop) => crop['name'].toString().toLowerCase() == cropType.toLowerCase(),
        orElse: () => null,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$cropType Production Plan"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadCropData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (snapshot.data == null) {
            return const Center(child: Text("Production details not found."));
          }

          var cropData = snapshot.data!;
          var details = cropData['details'];
          List instructions = cropData['instructions'] ?? [];
          List fertilizers = details['fertilizers'] ?? [];
          var seedPrep = details['seed_prepare'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Step-by-Step Growing Process",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 12),

                _buildStepCard("1", "Land Setup", details['prepare_land'] ?? "Prepare field bed thoroughly."),
                _buildStepCard("2", "Seed Treatment", "Fungicide: ${seedPrep['fungicide'] ?? 'N/A'}\nInsecticide: ${seedPrep['insecticide'] ?? 'N/A'}"),
                if (details['optimal_temperature'] != null)
                  _buildStepCard("3", "Climate Window", "Optimal Growth Temperature: ${details['optimal_temperature']}"),
                _buildStepCard("4", "Sowing Strategy", "Timeline: ${details['optimal_sowing_time'] ?? 'N/A'}\nDepth: ${details['seed_sowing_depth'] ?? 'N/A'}"),
                _buildStepCard("5", "Irrigation Flow", details['watering'] ?? "Water field timely."),
                _buildStepCard("6", "Weed Management", details['weeding'] ?? "Maintain clean soil base."),

                const SizedBox(height: 16),
                const Text(
                  "Required Fertilizers",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Wrap(
                      spacing: 8,
                      children: fertilizers.map((f) => Chip(
                        label: Text(f.toString(), style: const TextStyle(fontWeight: FontWeight.w500)),
                        backgroundColor: Colors.green.shade50,
                      )).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Useful Field Tips",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.amber.shade50,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.amber.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: instructions.map((ins) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text(ins.toString(), style: const TextStyle(fontSize: 14, color: Colors.black87))),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepCard(String index, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              radius: 13,
              child: Text(index, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}