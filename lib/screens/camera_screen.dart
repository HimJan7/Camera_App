import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/main.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late final size;
  late final deviceRatio;
  CameraController? controller;
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = true;
  final resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  bool _isCameraPermissionGranted = false;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  FlashMode? _currentFlashMode;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  double getRatio() {
    return ((MediaQuery.of(context).size.height)) /
        MediaQuery.of(context).size.width;
  }

  @override
  void initState() {
    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Column(
              children: [
                Expanded(
                    child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  color: Colors.black,
                  child: Stack(
                    children: [
                      CameraPreview(
                        controller!,
                      ),
                    ],
                  ),
                )),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.06,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.height * 0.2,
                              child: const Center(
                                  child: Text(
                                'VIDEO',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              )),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.height * 0.2,
                              child: const Center(
                                  child: Text(
                                'PHOTO',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              )),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.height * 0.2,
                              child: const Center(
                                  child: Text(
                                'PORTRAIT',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              )),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.height * 0.2,
                              child: const Center(
                                  child: Text(
                                'SLOMO',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              )),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isCameraInitialized = false;
                              });
                              onNewCameraSelected(
                                cameras[_isRearCameraSelected ? 0 : 1],
                              );
                              setState(() {
                                _isRearCameraSelected = !_isRearCameraSelected;
                              });
                            },
                            icon: Icon(Icons.cameraswitch),
                            color: Colors.white,
                            iconSize: MediaQuery.of(context).size.height * 0.06,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.circle),
                            color: Colors.white,
                            iconSize: MediaQuery.of(context).size.height * 0.08,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.slideshow),
                            color: Colors.white,
                            iconSize: MediaQuery.of(context).size.height * 0.06,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )
          : Container(),
    );
  }
}
