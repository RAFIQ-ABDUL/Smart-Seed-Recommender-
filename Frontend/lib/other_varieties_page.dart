import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtherVarietiesPage extends StatelessWidget {
  final String cropType;
  final String predictedSeed;

  const OtherVarietiesPage({
    super.key,
    required this.cropType,
    required this.predictedSeed,
  });

  Future<List<dynamic>> _loadAlternativeSeeds() async {
    try {
      final String response = await rootBundle.loadString('assets/data/crop_data.json');
      final data = json.decode(response);
      final List crops = data['crops'];

      var matchingCrop = crops.firstWhere(
            (crop) => crop['name'].toString().toLowerCase() == cropType.toLowerCase(),
        orElse: () => null,
      );

      if (matchingCrop != null) {
        List allSeeds = matchingCrop['seed_varieties'];
        // Filter out the seed that was predicted
        return allSeeds.where((seed) => seed['name'].toString().toLowerCase().trim() != predictedSeed.toLowerCase().trim()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alternative Options"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _loadAlternativeSeeds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          List seeds = snapshot.data ?? [];

          if (seeds.isEmpty) {
            return const Center(child: Text("No alternative varieties listed."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: seeds.length,
            itemBuilder: (context, index) {
              var seed = seeds[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: const Icon(Icons.grain, color: Colors.green),
                  ),
                  title: Text(
                    seed['name'] ?? 'Unknown Variety',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Market Price: ${seed['price_range']}",
                      style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}