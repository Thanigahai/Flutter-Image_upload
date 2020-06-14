import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class ImagePage extends StatefulWidget {
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  File _image, cropped,imageFile;
  var uuid = new Uuid();

  
  void _startUpload() async{
    
    //Create a unique random name for the file to upload
    var name = uuid.v4(options: {'rng': UuidUtil.cryptoRNG});
    
    //Instantiate a path for the files to be uploaded.
    final ref = FirebaseStorage.instance.ref().child('images/$name.jpg');
    
    //We will store the uploaded file's url in this variable to access later
    var url;

    //As the name says "putfile" is used to put your file (upload) in the firebase
  await ref.putFile(_image).onComplete.then((value) async{
    print("Inside then");
    url = await ref.getDownloadURL();
    print(url);
  });
  }
  
  Future _selectPicture() async {
    imageFile = await ImagePicker.pickImage(
      maxHeight: 512, 
      maxWidth: 512,
      source: ImageSource.gallery
    );
    imageFile!=null?_cropImage():null;
  }
  
  Future _takePicture() async {
    imageFile = await ImagePicker.pickImage(
//        imageQuality: 60,
        maxHeight: 512,
        maxWidth: 512,
        source: ImageSource.camera);
    imageFile!=null?_cropImage():null;
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
// //      aspectRatioPresets: [CropAspectRatioPreset.ratio5x4],
        aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
        sourcePath:imageFile.path,
        maxWidth: 512,
        maxHeight: 512);

    setState(() {
      _image = cropped_image ?? _image;
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
          : Center(child: Text("No image"),),
    );
  }
}


