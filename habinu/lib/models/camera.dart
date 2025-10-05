import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:habinu/models/chooseHabit.dart';

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
                  // Resume preview when this screen is built
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_controller.value.isInitialized) {
                      _controller.resumePreview();
                    }
                  });
                  return Center(child: CameraPreview(_controller));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            // Square viewfinder overlay - darkened areas
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;
                final squareSize = screenWidth; // Make square as wide as screen
                final topOffset = (screenHeight - squareSize) / 2;

                return Stack(
                  children: [
                    // Top dark overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: topOffset,
                      child: Container(color: Colors.black.withOpacity(0.6)),
                    ),
                    // Bottom dark overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: topOffset,
                      child: Container(color: Colors.black.withOpacity(0.6)),
                    ),
                  ],
                );
              },
            ),
            // X button overlay (top-left)
            xButtonClose(context),
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

  Future<void> uploadImage() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://172.16.226.154:3000/images"),
    );
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    var response = await request.send();
    if (response.statusCode == 200) {
      debugPrint('Image uploaded successfully!');
    } else {
      debugPrint('Image upload failed with status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) => {camera.resumePreview()},
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Cropped image display
            Center(
              child: AspectRatio(
                aspectRatio: 1.0, // Square aspect ratio
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(
                          context,
                        ).size.width, // Square dimensions
                        child: Image.file(File(image.path), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // X button overlay (top-left)
            xButtonClose(context),
            // Save button positioned below image on the right
            Positioned(
              top:
                  (MediaQuery.of(context).size.height / 2) +
                  (MediaQuery.of(context).size.width /
                      2), // Below the centered square image
              right: 20,
              child: SafeArea(
                child: SizedBox(
                  width: 80,
                  height: 50,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChooseHabit(imagePath: image.path),
                        ),
                      );
                    },
                    label: Text(
                      "Next",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    backgroundColor: Color(0xfffbb86a),
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

Widget xButtonClose(BuildContext context) {
  return Positioned(
    top: 50,
    left: 20,
    child: SafeArea(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(128),
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
  );
}
