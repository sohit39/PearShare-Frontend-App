import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'home.dart';
import 'model/product.dart';
import 'supplemental/product_card.dart';
import 'http_constant.dart';


class Camera extends StatefulWidget {
  @override
  _CameraState createState() {
    return new _CameraState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw new ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraState extends State<Camera> {
  CameraController controller;
  TextEditingController textController = new TextEditingController();
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  String answer = "Answer";
  String predictedEquation = "Predicted Equation";
  String operationForListView = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _progressBarActive = false;
  bool _simpsonBar = false;
  String simposonAnswer = "";
  var count = 0;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
//        appBar: new AppBar(
//          title: const Text('PhotoCalculus Calculator',
//            style: TextStyle(color: Colors.white, fontSize: 20.0),),
//          actions: <Widget>[
//            IconButton(
//              icon: Icon(Icons.history),
//              onPressed: () {
//                Navigator.push(context, EquationHistory());
//              },
//            ),
//          ],
//          backgroundColor: Colors.blue[900],
//
//        ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.chevron_left),
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.blue[900],),
      floatingActionButtonLocation: const _StartTopFloatingActionButtonLocation(),
      body: new Stack(children: <Widget>[new Column(
        children: <Widget>[
          new Expanded(
            child: new Container(
              child: new Padding(
                padding: const EdgeInsets.all(1.0),
                child: new Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: new BoxDecoration(
                color: Colors.blue[900],

              ),
            ),
          ),
//            new Container(padding: const EdgeInsets.all(5.0),
//                child: new Text(predictedEquation,
//                  style: TextStyle(color: Colors.black,
//                      fontSize: 20.0,),),  ),
//            //if loading, display indicator, else display Text
//            new Container(padding: const EdgeInsets.all(5.0),
//                child: _progressBarActive == true
//                    ? const CircularProgressIndicator(
//                  backgroundColor: Colors.red,)
//                    : new Text(answer,
//                  style: TextStyle(color: Colors.black,
//                      fontSize: 20.0),)),
//            _simpsonBar == false ? new Container() : new Container(
//                padding: const EdgeInsets.all(5.0),
//                child: _progressBarActive == true
//                    ? const CircularProgressIndicator(
//                  backgroundColor: Colors.red,)
//                    : new Container(
//                    color: Colors.blue[200], child: new Text(simposonAnswer,
//                  style: TextStyle(color: Colors.black,
//                      fontSize: 20.0),))),
          /*new Container(color: Colors.blue[900],
                child: new Padding(padding: const EdgeInsets.all(5.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _cameraTogglesRowWidget(),
                      _thumbnailWidget(),
                    ],
                  ),
                )),*/
        ],
      )]),
      bottomNavigationBar: new BottomAppBar(
        color: Colors.blue[900],
        child:  _captureControlRowWidget(),
      ),
    );
  }

  int hexToInt(String hex)
  {
    int val = 0;
    int len = hex.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = hex.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        // A..F
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        // a..f
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        throw new FormatException("Invalid hexadecimal value");
      }
    }
    return val;
  }
  void initializeCam() async {
    CameraDescription a;
    if (Platform.operatingSystem == "android") {
      a = new CameraDescription(
          name: "0", lensDirection: CameraLensDirection.back);
    }
    else {
      a = new CameraDescription(
          name: "com.apple.avfoundation.avcapturedevice.built-in_video:0", lensDirection: CameraLensDirection.back);
    }
    controller = new CameraController(a, ResolutionPreset.high);
    if (controller != null) {
      await controller.dispose();
    }
    controller = new CameraController(a, ResolutionPreset.high);
    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }
  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      initializeCam();
      return const Text(
        'No Camera Available',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return new CameraPreview(controller);
//      return new AspectRatio(
//        aspectRatio: controller.value.aspectRatio,
//        child: new CameraPreview(controller),
//      );
    }

  }

  /// Display the thumbnail of the captured image or video.
  /*Widget _thumbnailWidget() {
    return new Expanded(
      child: new Align(
        alignment: Alignment.centerRight,
        child: videoController == null && imagePath == null
            ? null
            : new SizedBox(
          child: (videoController == null)
              ? new Image.file(new File(imagePath))
              : new Container(
            child: new Center(
              child: new AspectRatio(
                  aspectRatio: videoController.value.size != null
                      ? videoController.value.aspectRatio
                      : 1.0,
                  child: new VideoPlayer(videoController)),
            ),
            decoration: new BoxDecoration(
                border: new Border.all(color: Colors.pink)),
          ),
          width: 64.0,
          height: 64.0,
        ),
      ),
    );
  }*/

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return
      new IconButton(
        color: Colors.white,
        highlightColor: Colors.blue[900],
        icon: const Icon(Icons.camera_alt),
        iconSize: 40.0,
        onPressed: controller != null &&
            controller.value.isInitialized &&
            !controller.value.isRecordingVideo
            ? onTakePictureButtonPressed
            : null,
      );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  /*Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          new SizedBox(
            width: 90.0,
            child: new RadioListTile<CameraDescription>(
              title:
              new Icon(getCameraLensIcon(cameraDescription.lensDirection), color: Colors.black,),
              activeColor: Colors.black,
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: controller != null && controller.value.isRecordingVideo
                  ? null
                  : onNewCameraSelected,
            ),
          ),
        );
      }
    }

    return new Row(children: toggles);
  }*/

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = new CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    setState(() {
      _simpsonBar = false;
    });
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => ItemForm(filePath)),
          );
        }

      }
    });
  }


  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';
    if (controller.value.isTakingPicture) {
      return null;
    }
    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
  void showAnswers() {
    String finalText = "";

    if(!(predictedEquation == "Predicted Equation"))
      finalText+=predictedEquation+ "\n";
    finalText+=answer;
    if(_simpsonBar == true)
      finalText+= "\n" + simposonAnswer;
    showModalBottomSheet<void>(
        context: context, builder: (BuildContext context) {
      return new Container(
          child: new Padding(
              padding: const EdgeInsets.all(30.0),
              child: new Text(finalText,
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      color: Colors.blue[900],
                      fontSize: 18.0
                  )
              )
          )
      );
    });
  }
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Camera(),
    );
  }
}

List<CameraDescription> cameras;

Future<Null> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(new CameraApp());
}

class ProductData {
  String imagefilepath = "";
  String itemName = "";
  int cost = 0;
  String expiryDate = "";
}



class ItemForm extends StatefulWidget {
  @override
  String filepath;
  ItemForm (String fp) {
    filepath = fp;
  }
  State<StatefulWidget> createState() => new ItemFormState(filepath);
}

class ItemFormState extends State<ItemForm> {
  static String filepath = "";
  ItemFormState(String fp) {
    filepath = fp;
  }
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  ProductData _data = new ProductData();
  static var assetImage = new AssetImage(filepath);
  static var image = new Image(image: assetImage);

  handleSuccess(http.Response response) {
    print("here");
    print(response);
    return;
  }

  handleFailure(error) {
    print("error");
    print(error.toString());
    return;
  }

  void submit() {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.
      print('Printing the login data.');
      print(_data.expiryDate);
      print(_data.cost);
      print(_data.itemName);
      var prod = Product(category: Category.all, name: _data.itemName, price: _data.cost, id: 99, fp: filepath, expiry: _data.expiryDate);
      var c = ProductCard(product: prod,);
      HomePageState.b.addFirst(c);
      File imageFile = new File(filepath);
      List<int> imageBytes = imageFile.readAsBytesSync();
      Base64Encoder base64Encoder = new Base64Encoder();
      String base64 = base64Encoder.convert(imageBytes);
      JsonEncoder jsonEncoder = new JsonEncoder();
      var body = jsonEncoder.convert({'title': _data.itemName, 'image_b64_addr': base64, "description": "Fresh Food for Very Good Price, Please Buy!", "seller": 1, "best_before_date": _data.expiryDate,   "price": _data.cost, });
      http.post(kBASE_URL + "items/", headers: {'Content-Type': 'application/json'},body: body).then(handleSuccess).catchError(handleFailure);
      Navigator.pop(context);
    }
  }

  void onClicked () {
    print("hello");
  }
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Enter Item Data'),
      ),
      body: new Container(
          color: const Color(0xFFFFFFFF),
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            key: this._formKey,
            child: new ListView(
              children: <Widget>[
                new AspectRatio(aspectRatio: 15/16,
                child: image),
                new SizedBox(height: 3.0),
                new TextFormField(
                    keyboardType: TextInputType.emailAddress, // Use email input type for emails.
                    decoration: new InputDecoration(
                        hintText: 'Pears',
                        labelText: 'Name of Item'
                    ),
                    autocorrect: true,
                    style: TextStyle(
                      color: Colors.blue[900],
                    ),

                    onSaved: (String value) {
                      this._data.itemName = value;
                    }

                ),
                new SizedBox(height: 10.0,),
                new TextFormField(
                    decoration: new InputDecoration(
                        hintText: '12',
                        labelText: 'Cost'
                    ),
                    onSaved: (String value) {
                      this._data.cost = int.parse(value);
                    },
                  style: TextStyle(
                    color: Colors.blue[900],
                  ),
                ),
                new SizedBox(height: 10.0,),
                new TextFormField(
                    decoration: new InputDecoration(
                        hintText: 'YYYY-MM-DD',
                        labelText: 'Expiry Date'
                    ),
                    onSaved: (String value) {
                      this._data.expiryDate = value;
                    },
                  style: TextStyle(
                    color: Colors.blue[900],
                  ),
                ),
                new SizedBox(height: 5.0,),
                new Container(
                  width: screenSize.width,
                  child: new RaisedButton(
                    child: new Text(
                      'Finish',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    ),
                    onPressed: this.submit,
                    color: Colors.blue[900],
                    elevation: 8.0,
                  ),
                  margin: new EdgeInsets.only(
                      top: 20.0
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}
//From Flutter Example Gallery
// Places the Floating Action Button at the top of the content area of the
// app, on the border between the body and the app bar.
class _StartTopFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const _StartTopFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // First, we'll place the X coordinate for the Floating Action Button
    // at the start of the screen, based on the text direction.
    double fabX;
    assert(scaffoldGeometry.textDirection != null);
    switch (scaffoldGeometry.textDirection) {
      case TextDirection.rtl:
      // In RTL layouts, the start of the screen is on the right side,
      // and the end of the screen is on the left.
      //
      // We need to align the right edge of the floating action button with
      // the right edge of the screen, then move it inwards by the designated padding.
      //
      // The Scaffold's origin is at its top-left, so we need to offset fabX
      // by the Scaffold's width to get the right edge of the screen.
      //
      // The Floating Action Button's origin is at its top-left, so we also need
      // to subtract the Floating Action Button's width to align the right edge
      // of the Floating Action Button instead of the left edge.
        final double startPadding = kFloatingActionButtonMargin + scaffoldGeometry.minInsets.right;
        fabX = scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width - startPadding;
        break;
      case TextDirection.ltr:
      // In LTR layouts, the start of the screen is on the left side,
      // and the end of the screen is on the right.
      //
      // Placing the fabX at 0.0 will align the left edge of the
      // Floating Action Button with the left edge of the screen, so all
      // we need to do is offset fabX by the designated padding.
        final double startPadding = kFloatingActionButtonMargin + scaffoldGeometry.minInsets.left;
        fabX = startPadding;
        break;
    }
    // Finally, we'll place the Y coordinate for the Floating Action Button
    // at the top of the content body.
    //
    // We want to place the middle of the Floating Action Button on the
    // border between the Scaffold's app bar and its body. To do this,
    // we place fabY at the scaffold geometry's contentTop, then subtract
    // half of the Floating Action Button's height to place the center
    // over the contentTop.
    //
    // We don't have to worry about which way is the top like we did
    // for left and right, so we place fabY in this one-liner.
    final double fabY = 25 + scaffoldGeometry.contentTop - (scaffoldGeometry.floatingActionButtonSize.height / 2.0)*0.0;
    return new Offset(fabX, fabY);
  }
}


