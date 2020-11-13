import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _outputs;
  File _image;
  bool _loading;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Agro-Disease-Detector')),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            _loading ?
            Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
                : Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  if(_image == null)
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Center(child: Text(
                        'Choose Image', style: TextStyle(fontSize: 20),)),
                    ),

                  _image == null ? Container() : Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Image.file(_image),
                  ),

                  SizedBox(height: 30,),
                  _outputs == null ? Text("") :
                  Center(
                    child: Text(
                      "${"Here is the disease diagnosis:\n" + _outputs[0]["label"]}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,),
                    ),
                  ),
                  if(_outputs != null)
                    Center(
                      child: Text("\n\n Confidence: "+_outputs[0]["confidence"].toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,),
                      ),
                    )

                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.image),
      ),
    );
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }
}

loadModel() async {
  await Tflite.loadModel(
    model: "assets/model_add.tflite",
    labels: "assets/add_labels.txt",
  );
}
