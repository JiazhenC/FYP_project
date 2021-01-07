import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Vehicle_Detail_Page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
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
      isAsset:
          true, // defaults to true, set to false to load resources outside assets
      useGpuDelegate:
          false // defaults to false, set to true to use GPU delegate
      );
  runApp(MaterialApp(home: Scaffold(body: MainPage())));
}

class MainPage extends StatefulWidget {
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextRecognizer textRecognizer =
      FirebaseVision.instance.textRecognizer();
  var detected = [];
  bool isDetecting = false;
  bool systemRun = false;
  CameraController controller;
  String recognizedText = "No recognized text";
  String messageText = "Initialize Object Detection Model";

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if(!mounted){
        return;
      }
      setState(() {});
      controller.startImageStream((CameraImage image) {
        if (!isDetecting) {
          isDetecting = true;
          messageText="Point the camera to the license plate.";
          systemRun=true;
          setState(() {
          });

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
              threshold: 0.5,
              asynch: true)
              .then((recognition) {
            detected = [];
            for (int i = 0; i < recognition.length; i++) {
              detected.add(recognition[i]['detectedClass']);
            }
            if (detected.contains('car') == true) {
              messageText="Car detected";
              setState(() {
              });
              readPlate(
                  image,
                  recognition[detected.indexOf('car')]['rect']['x'],
                  recognition[detected.indexOf('car')]['rect']['y'],
                  recognition[detected.indexOf('car')]['rect']['w'],
                  recognition[detected.indexOf('car')]['rect']['h']);
            }else{
              isDetecting = false;
            }
          });
        }
      });
    });
  }

  void readPlate(
      CameraImage image, double x, double y, double w, double h) async {
    x = x * image.height;
    y = y * image.width;
    w = w * image.height;
    h = h * image.width;
    double car_l = x;
    double car_r = x + w;
    double car_t = y;
    double car_b = y + h;
    FirebaseVisionImageMetadata metadata =
        metaData(image, ImageRotation.rotation90);
    FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromBytes(image.planes[0].bytes, metadata);
    VisionText visionText = await textRecognizer.processImage(visionImage);
    for (TextBlock block in visionText.blocks) {
      final Rect boundingBox = block.boundingBox;
      double l = boundingBox.left;
      double r = boundingBox.right;
      double t = boundingBox.top;
      double b = boundingBox.bottom;
      if ((car_l <= l) && (car_r >= r) && (car_t <= t) && (car_b >= b)) {
        if((block.text.contains(new RegExp(r'[A-Z]'))||block.text.contains(new RegExp(r'[a-z]')))&&block.text.contains(new RegExp(r'[0-9]'))) {
          recognizedText = block.text;
          messageText = "License Plate is Detected";
          setState(() {});
          return;
        }
      }
    }
    isDetecting=false;
  }

  FirebaseVisionImageMetadata metaData(
    CameraImage image,
    ImageRotation rotation,
  ) {
    return FirebaseVisionImageMetadata(
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      planeData: image.planes
          .map(
            (plane) => FirebaseVisionImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width,
            ),
          )
          .toList(),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (systemRun==false) {
      return Container(
        child: Icon(
          Icons.cancel_rounded
        ),
      );
    }
    return ListView(
      children: [
        Stack(
          children: [
            AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller)),
            Center(
                child:Container(
                  color: Colors.white,
                    child: Text(messageText,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
                )
            ),
          ],
        ),
        Row(
          children: [
            TextButton(
                child: Text(recognizedText),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: (){isDetecting=false;},
            ),
            IconButton(icon: Icon(Icons.check), onPressed: (){Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    Vehicle_Detail_Page(vehicleID: recognizedText)));}),
            IconButton(icon: Icon(Icons.edit), onPressed: (){Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    Vehicle_Detail_Page(vehicleID: recognizedText)));})
          ],
        ),
      ],
    );
  }
}