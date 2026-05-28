import 'package:flutter/material.dart';

enum CropType { maize, cotton, rice, wheat }

class CropSelectionPage extends StatelessWidget {
  final Function(CropType crop) onCropSelect;

  const CropSelectionPage({
    super.key,
    required this.onCropSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Seed Recommender"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFA5D6A7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Your Crop",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Choose a crop type below to input parameters and find the best verified variety for the Pakistani market.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // Crop cards grid
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 900
                    ? 4
                    : MediaQuery.of(context).size.width > 600
                    ? 2
                    : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _cropCard(
                    title: "Maize (مکئی)",
                    description: "Corn variety optimization",
                    icon: Icons.spa,
                    color: Colors.orange.shade600,
                    onTap: () => onCropSelect(CropType.maize),
                  ),
                  _cropCard(
                    title: "Cotton (کپاس)",
                    description: "Cotton yield & seed optimization",
                    icon: Icons.eco,
                    color: Colors.teal.shade600,
                    onTap: () => onCropSelect(CropType.cotton),
                  ),
                  _cropCard(
                    title: "Rice (چاول)",
                    description: "Paddy variety analysis",
                    icon: Icons.grass,
                    color: Colors.green.shade700,
                    onTap: () => onCropSelect(CropType.rice),
                  ),
                  _cropCard(
                    title: "Wheat (گندم)",
                    description: "Wheat variety prediction",
                    icon: Icons.agriculture,
                    color: Colors.amber.shade700,
                    onTap: () => onCropSelect(CropType.wheat),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // How it works info card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "How It Works",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      SizedBox(height: 16),
                      _StepWidget(step: "1", text: "Select your targeted crop type from the dashboard."),
                      _StepWidget(
                          step: "2",
                          text: "Enter specific regional parameters (Soil profile, climate metrics, NPK variants)."),
                      _StepWidget(
                          step: "3",
                          text: "Get a data-backed recommendation of the top performing seeds available in the Pakistani market."),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cropCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text("Select", style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _StepWidget extends StatelessWidget {
  final String step;
  final String text;

  const _StepWidget({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade100,
            radius: 16,
            child: Text(step, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(
                  text,
                  style: const TextStyle(fontSize: 14, color: Colors.black87)
              )
          ),
        ],
      ),
    );
  }
}