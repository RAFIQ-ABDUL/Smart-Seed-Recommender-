import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


import 'package:flutter/material.dart';
import 'crop_selection_page.dart';
import 'feature/maize_feature_page.dart';
import 'feature/cotton_feature_page.dart';
import 'feature/rice_feature_page.dart';
import 'feature/wheat_feature_page.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seed Recommender',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  CropType? selectedCrop;

  @override
  Widget build(BuildContext context) {
    // 1. If no crop is selected, immediately show the selection dashboard
    if (selectedCrop == null) {
      return CropSelectionPage(
        onCropSelect: (crop) => setState(() => selectedCrop = crop),
      );
    }

    // 2. Route directly to the corresponding page layout without phone parameters
    switch (selectedCrop!) {
      case CropType.maize:
        return MaizeFeaturePage(
          onBack: () => setState(() => selectedCrop = null),
        );
      case CropType.cotton:
        return CottonFeaturePage(
          onBack: () => setState(() => selectedCrop = null),
        );
      case CropType.rice:
        return RiceFeaturePage(
          onBack: () => setState(() => omittedCropSelection()),
        );
      case CropType.wheat:
        return WheatFeaturePage(
          onBack: () => setState(() => selectedCrop = null),
        );
    }
  }

  void omittedCropSelection() {
    selectedCrop = null;
  }
}