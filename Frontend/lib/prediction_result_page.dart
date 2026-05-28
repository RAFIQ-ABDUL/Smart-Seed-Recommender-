import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'production_management_page.dart';
import 'other_varieties_page.dart';

class PredictionResultPage extends StatelessWidget {
  final String cropType; // 'Maize', 'Cotton', 'Rice', 'Wheat'
  final String predictedSeed;

  const PredictionResultPage({
    super.key,
    required this.cropType,
    required this.predictedSeed,
  });

  Future<Map<String, dynamic>?> _loadCropData(BuildContext context) async {
    try {
      final String response = await rootBundle.loadString('assets/data/crop_data.json');
      final data = json.decode(response);
      final List crops = data['crops'];
      return crops.firstWhere(
            (crop) => crop['name'].toString().toLowerCase() == cropType.toLowerCase(),
        orElse: () => null,
      );
    } catch (e) {
      debugPrint("Error loading JSON: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recommendation Details"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadCropData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          Map<String, dynamic>? currentCropData = snapshot.data;
          Map<String, dynamic>? matchingSeed;

          if (currentCropData != null) {
            List varieties = currentCropData['seed_varieties'];
            matchingSeed = varieties.firstWhere(
                  (seed) => seed['name'].toString().toLowerCase().trim() == predictedSeed.toLowerCase().trim(),
              orElse: () => null,
            );
          }

          String priceRange = matchingSeed != null ? matchingSeed['price_range'] : "Price data unavailable";
          String expectedYield = matchingSeed != null ? matchingSeed['yield'] : "Yield data unavailable";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.green.withOpacity(0.1),
                          child: const Icon(Icons.verified, color: Colors.green, size: 36),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "${cropType.toUpperCase()} SEED RECOMMENDATION",
                          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          predictedSeed,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const Divider(height: 32, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.payments, color: Colors.teal, size: 22),
                                SizedBox(width: 8),
                                Text("Estimated Price", style: TextStyle(fontSize: 15, color: Colors.black54)),
                              ],
                            ),
                            Expanded(
                              child: Text(
                                priceRange,
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.analytics, color: Colors.orange, size: 22),
                                SizedBox(width: 8),
                                Text("Expected Yield", style: TextStyle(fontSize: 15, color: Colors.black54)),
                              ],
                            ),
                            Expanded(
                              child: Text(
                                expectedYield,
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.assignment, size: 22),
                  label: const Text("Production Management Plan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductionManagementPage(cropType: cropType),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.grass, size: 22, color: Colors.green),
                  label: const Text("Other Seed Varieties", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherVarietiesPage(
                          cropType: cropType,
                          predictedSeed: predictedSeed,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}