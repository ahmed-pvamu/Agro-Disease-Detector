import 'dart:io';
import 'package:flutter/cupertino.dart';
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
        title: Center(child: const Text('Plant Disease Detector')),textTheme: TextTheme(
      title: TextStyle(fontSize: 35.0,fontWeight: FontWeight.bold)
    ),

      ),

      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/image1.png'),
                  fit: BoxFit.fitHeight
              )
          ),


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
                        'Choose Image', style: TextStyle(fontSize: 45,fontWeight: FontWeight.bold,color: Colors.white),)
                      ),


                    ),
                  // Center(
                  //   child: Column(
                  //     children: [
                  //       Image.asset('assets/image.png',
                  //       width: 600.0,
                  //       height: 1000.0,
                  //       fit: BoxFit.fill,)
                  //     ],
                  //   ),
                  // ),

                  _image == null ? Container() : Container(decoration: BoxDecoration(color: Colors.white,border:Border.all()),
                  padding: const EdgeInsets.all(40.0),
                  child: Image.file(_image),),
                  // Padding(
                  //   padding: const EdgeInsets.all(30.0),
                  //   child: Image.file(_image),



                  SizedBox(height: 30,),
                  _outputs == null ? Text("") :
                  Center(
                    child: Text(
                      "${"Detected Disease :\n" + _outputs[0]["label"]}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 35.0,),
                    ),
                  ),
                  if(_outputs != null)
                    Center(
                      child: Text("\n Confidence : "+_outputs[0]["confidence"].toStringAsFixed(2),
                      style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35.0,),
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
