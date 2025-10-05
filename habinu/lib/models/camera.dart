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
      MaterialPageRoute(builder: (context) => DisplayPictureScreen(image: image, camera: _controller))
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Take a picture!"),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try { 
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            _controller.pausePreview();
            toDisplayImagePage(image);
          } catch (e) { 
            debugPrint(e.toString());
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final XFile image;
  final CameraController camera;

  const DisplayPictureScreen({super.key, required this.image, required this.camera});

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
      onPopInvokedWithResult: (didPop, result) => {
        camera.resumePreview()
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Displayed Image"),
        ),
         body: Center(child: Image.file(File(image.path))),
         floatingActionButton: FloatingActionButton(onPressed: savePicture),
         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}