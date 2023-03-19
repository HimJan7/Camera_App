import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/screens/camera_screen.dart';

List<CameraDescription> cameras = [];
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Camera App',
      debugShowCheckedModeBanner: false,
      home: CameraScreen(),
    );
  }
}
