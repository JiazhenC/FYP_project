import 'package:flutter/material.dart';
import 'Vehicle_Detail_Page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  String res = await Tflite.loadModel(
      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/ssd_mobilenet.txt",
      numThreads: 1, // defaults to 1
      isAsset: true, // defaults to true, set to false to load resources outside assets
      useGpuDelegate: false // defaults to false, set to true to use GPU delegate
  );
  runApp(MaterialApp(home: Scaffold(body: MainPage())));
}

class MainPage extends StatefulWidget {
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _controller = TextEditingController();
  bool isDetecting = false;
  CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      controller.startImageStream((image){
        if(!isDetecting) {
          isDetecting=true;
          Tflite.detectObjectOnFrame(
              bytesList: image.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              model: "SSDMobileNet",
              imageWidth: image.width,
              imageHeight: image.height,
              imageMean: 127.5,
              imageStd: 127.5,
              rotation: 90,
              numResultsPerClass: 1,
              threshold: 0.4,
              asynch: true
          ).then((recognition) {
            while(recognition.length>0){
              var listItem = recognition.removeLast();
              if(listItem['detectedClass']=='person'){

              }else{
                isDetecting=false;
              }
            }
            isDetecting=false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Text("Loading the camera");
    }
    return AspectRatio(
        aspectRatio:
        controller.value.aspectRatio,
        child: CameraPreview(controller)
    );
  }
}

/*
  FutureBuilder<void>(
  future: controller.initialize(),
  builder: (context, snapshot) {
  if (snapshot.connectionState == ConnectionState.done) {
  controller.startImageStream((image){
  Tflite.detectObjectOnFrame(
  bytesList: image.planes.map((plane){
  return plane.bytes;
  }).toList(),
  model: "SSDMobileNet",
  imageWidth:image.width,
  imageHeight: image.height,
  imageMean: 127.5,
  imageStd: 127.5,
  rotation: 90,
  numResultsPerClass: 1,
  threshold: 0.1,
  asynch: true
  ).then((recognition){
  print(recognition);
  });
  });
  // If the Future is complete, display the preview.
  return Scaffold(
  floatingActionButton: FloatingActionButton(
  child: Icon(Icons.search),
  onPressed: () {
  dispose();
  Navigator.of(context).push(MaterialPageRoute(
  builder: (context) => Vehicle_Detail_Page(
  vehicleID: _controller.text
      .toUpperCase()
      .replaceAll(RegExp(r"\s"), ""))));
  }),
  body: ListView(
  children: [
  AspectRatio(
  aspectRatio: controller.value.aspectRatio,
  child: CameraPreview(controller)
  ),
  TextField(
  controller: _controller,
  ),
  ],
  ));
  } else {
  // Otherwise, display a loading indicator.
  return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
  });

 */