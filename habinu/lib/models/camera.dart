import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraPageState extends StatefulWidget {
  final CameraDescription camera;

  const CameraPageState({super.key, required this.camera});

  @override
  State<CameraPageState> createState() => CameraPage();
}

class CameraPage extends State<CameraPageState> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late FocusNode focusNode;

  void toDisplayImagePage(XFile image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DisplayPictureScreen(image: image, camera: _controller),
      ),
    );
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      _controller.resumePreview();
    } else {
      _controller.pausePreview();
    }
  }

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();
    focusNode.addListener(onFocusChange);

    _controller = CameraController(widget.camera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext build) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) => {_controller.pausePreview()},
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Centered camera preview with correct aspect ratio
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(child: CameraPreview(_controller));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            // X button overlay (top-left)
            Positioned(
              top: 50,
              left: 20,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Circular photo button overlay (bottom-center)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        await _initializeControllerFuture;
                        final image = await _controller.takePicture();
                        _controller.pausePreview();
                        toDisplayImagePage(image);
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final XFile image;
  final CameraController camera;

  const DisplayPictureScreen({
    super.key,
    required this.image,
    required this.camera,
  });

  void savePicture() async {
    final path = await _localPath;
    final fileName = image.name;
    await image.saveTo("$path/$fileName");
    debugPrint("$path/$fileName");
  }

  Future<String> get _localPath async {
    final localDirectory = await getApplicationDocumentsDirectory();
    return localDirectory.path;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) => {camera.resumePreview()},
      child: Scaffold(
        appBar: AppBar(title: const Text("Displayed Image")),
        body: Center(child: Image.file(File(image.path))),
        floatingActionButton: FloatingActionButton(onPressed: savePicture),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
