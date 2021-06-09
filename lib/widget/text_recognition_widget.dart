import 'dart:io';
import 'dart:convert';
import 'package:firebase_ml_text_recognition/api/firebase_ml_api.dart';
import 'package:firebase_ml_text_recognition/widget/solution_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'controls_widget.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class TextRecognitionWidget extends StatefulWidget {
  const TextRecognitionWidget({
    Key key,
  }) : super(key: key);

  @override
  _TextRecognitionWidgetState createState() => _TextRecognitionWidgetState();
}

class _TextRecognitionWidgetState extends State<TextRecognitionWidget> {
  String text = '';
  File image;
  String url =
      'https://www.googleapis.com/customsearch/v1?key=AIzaSyCNtRyyvVhjGHHfNwidQrqNv0tOY06Ca-o&cx=2dd7c1cc02ea93b09&q=';

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Expanded(child: buildImage()),
            const SizedBox(height: 16),
            ControlsWidget(
              onClickedPickImage: pickImage,
              onClickedScanText: scanText,
              onClickedClear: clear,
            ),
          ],
        ),
      );

  Widget buildImage() => Container(
      child: image != null
          ? Column(
              children: [
                Flexible(child: Image.file(image)),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 72.0,
                        height: 48.0,
                        child: ElevatedButton(
                          child: Icon(
                            Icons.crop,
                            size: 32,
                          ),
                          onPressed: _cropImage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '1. Take a photo of the question.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  '2. Crop the image.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  '3. Search!',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ));

  Future pickImage() async {
    final file = await ImagePicker().getImage(source: ImageSource.camera);
    setImage(File(file.path));
  }

  Future scanText() async {
    if (image != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      var text = await FirebaseMLApi.recogniseText(image);
      setText(text);

      var response = await http.get(Uri.encodeFull(url + text));
      var converted = json.decode(response.body);
      var solution = converted['items'][0]['link'];

      Navigator.of(context).pop();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SolutionView(url: solution)));
      clear();
    } else {
      Fluttertoast.showToast(
        msg: "Please choose an image!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: image.path,
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Edit',
          toolbarColor: Colors.purple,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.purple,
          statusBarColor: Colors.purple,
          lockAspectRatio: false),
    );

    setState(() {
      image = cropped ?? image;
    });
  }

  void clear() {
    image.delete();
    setImage(null);
    setText('');
  }

  void setImage(File newImage) {
    setState(() {
      image = newImage;
    });
  }

  void setText(String newText) {
    setState(() {
      text = newText;
    });
  }
}
