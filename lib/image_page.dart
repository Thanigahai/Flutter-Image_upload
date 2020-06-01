import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ImagePage extends StatefulWidget {
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  File _image, cropped,imageFile;
  final FirebaseStorage _storage =
  FirebaseStorage(storageBucket: 'gs://image-upload-firebase-9347f.appspot.com');
  StorageUploadTask _uploadTask;

  /// Starts an upload task
  void _startUpload() {

    /// Unique file name for the file
    String filePath = 'images/${DateTime.now()}.png';

    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(_image);
    });
  }


  Future _selectPicture() async {
    print("inside function");
    imageFile = await ImagePicker.pickImage(
        maxHeight: 512, maxWidth: 512, source: ImageSource.gallery);
    _cropImage();
    print("3");
  }
  Future _takePicture() async {
    print("inside function");
    imageFile = await ImagePicker.pickImage(
//        imageQuality: 60,
        maxHeight: 512,
        maxWidth: 512,
        source: ImageSource.camera);
//    imageFile.path!=null?_cropImage():null;
    _cropImage();
    print("3");
  }

  Future<void> _cropImage() async {

    final cropped_image = await ImageCropper.cropImage(
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        androidUiSettings: AndroidUiSettings(
          activeControlsWidgetColor: Colors.amber,
          toolbarColor: Colors.amber,
          lockAspectRatio: true,
        ),
        iosUiSettings: IOSUiSettings(
          aspectRatioLockEnabled: true,
        ),
//      aspectRatioPresets: [CropAspectRatioPreset.ratio5x4],
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        sourcePath:imageFile.path,
        maxWidth: 512,
        maxHeight: 512);

    setState(() {
      _image = cropped_image ?? _image;
//      CircularProgressIndicator();
      _startUpload();

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photo"),
      ),
      body: body(context),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.add_event,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add_a_photo),
            label: "Camera",
            onTap: _takePicture,
          ),
          SpeedDialChild(
            child: Icon(Icons.image),
            label: "Gallery",
            onTap: _selectPicture,
          ),
        ],
      ),
    );
  }

  Widget body(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: _image != null
          ? Image.file(
              _image,
//              fit: BoxFit.cover,
              width: double.infinity,
            )
          : Text("No image"),
    );
  }
}


