
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictok/main.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:video_player/video_player.dart';
Map<String, dynamic> currentpost = {'title': null, 'caption': null};
class ImageCapture extends StatefulWidget {
  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
VideoPlayerController  _videoPlayerController;
VideoPlayerController  _cameraVideoPlayerController;
  File _imageFile;
  Future<void> _pickImage(ImageSource source) async {
    File selected=await ImagePicker.pickImage(source: source);
    setState(() {
      _imageFile=selected;
    });
}

  File _video;
  _pickVideo() async {
    File video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    _video = video;
     _videoPlayerController = VideoPlayerController.file(_video)..initialize().then((_) {
      setState(() { });
      _videoPlayerController.play();
    });
  }

  File _cameraVideo;
  _pickVideoFromCamera() async {
    File video = await ImagePicker.pickVideo(source: ImageSource.camera);
    _cameraVideo = video;
   _cameraVideoPlayerController = VideoPlayerController.file(_cameraVideo)..initialize().then((_) {
      setState(() { });
      _cameraVideoPlayerController.play();
    });
  }

Future<void> _cropImage()async{
    File cropped=await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        androidUiSettings: AndroidUiSettings(
            initAspectRatio: CropAspectRatioPreset.square,
        ),
    );
    setState(() {
      _imageFile=cropped ?? _imageFile;
    });
}


bool photocapture=true;
void clear(){
    setState(() {
      _imageFile=null;
      _video=null;
    });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            if(photocapture)IconButton(
              icon: Icon(Icons.photo_camera,size: MediaQuery.of(context).size.width*0.08,),
              onPressed: ()=>_pickImage(ImageSource.camera),
            ),
            if(!photocapture)IconButton(
              icon: Icon(Icons.videocam,size: MediaQuery.of(context).size.width*0.08,),
              onPressed: ()=>_pickVideoFromCamera(),
            ),
            if(photocapture)IconButton(
              icon: Icon(Icons.photo_library,size: MediaQuery.of(context).size.width*0.08),
              onPressed: ()=>_pickImage(ImageSource.gallery),
            ),
            if(!photocapture)IconButton(
              icon: Icon(Icons.video_library,size: MediaQuery.of(context).size.width*0.08),
              onPressed: ()=>_pickVideo(),
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:84.0,vertical: 8.0),
                child: ToggleSwitch(
                    minWidth: 95.0,
                    cornerRadius: 20,
                    activeBgColor: Colors.blueAccent,
                    activeTextColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveTextColor: Colors.white,
                    labels: ['Photo', 'Video'],
                    icons: [Icons.photo, Icons.videocam],
                    onToggle: (index) {
                      if(index==0){
                        setState(() {
                          photocapture=true;
                        });
                      }else if(index==1){
                        setState(() {
                          photocapture=false;
                        });
                      }
                    }),
              ),
            ],
          ),
          if(_imageFile!=null) ...[
            Image.file(_imageFile),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(child: Icon(Icons.crop),onPressed:_cropImage,),
                FlatButton(child: Icon(Icons.refresh),onPressed: clear),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Uploader(file:_imageFile),
            ),
          ]
         ,

          if(_video!=null) ...[
            _videoPlayerController.value.initialized
                ? AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController),
            )
                : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(child: Icon(Icons.refresh),onPressed: clear),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: VideoUploader(file:_video),
            ),
          ],

          if(_cameraVideo!=null) ...[
            _videoPlayerController.value.initialized
                ? AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController),
            )
                : Container(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: VideoUploader(file:_cameraVideo),
            ),
          ],

          if(_video==null&&_imageFile==null)
            Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top:80.0),
                  child: Text("Select Media From\nGallery", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w700),textAlign: TextAlign.center,),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class Uploader extends StatefulWidget {
  final File file;
  Uploader({Key key,this.file}) : super(key:key);
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage=FirebaseStorage(storageBucket: "gs://counsel-c7678.appspot.com");
  StorageUploadTask _task;
  void startUpload(){
    String filePath='images/${DateTime.now()}.png';
    setState(() {
      _task=_storage.ref().child(filePath).putFile(widget.file);
    });
  }
  @override
  Widget build(BuildContext context) {
    if(_task!=null){
      return StreamBuilder<StorageTaskEvent>(
        stream: _task.events,
        builder: (context,snapshot){
          var event=snapshot?.data?.snapshot;
          double progressPercent= event !=null ?
              event.bytesTransferred/event.totalByteCount:0;
          return Column(
            children: <Widget>[
              if(_task.isComplete)
                Text("Upload Complete!",style: TextStyle(color: Colors.black,fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700),),
              if(_task.isPaused)
                FloatingActionButton(
                  heroTag: 1,
                  child: Icon(Icons.play_arrow),
                  onPressed: ()=>_task.isInProgress,
                ),
              if(_task.isInProgress)
              FloatingActionButton(
                heroTag: 2,
                child: Icon(Icons.pause),
                onPressed: ()=>_task.isPaused,
              ),
              Center(
                child: Text(
                  "${(progressPercent*100).toStringAsFixed(2)}%",
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white,
                  value:progressPercent,
                ),
              ),],
          );
        },
      );
    }else{
      return FlatButton.icon(
        label:Text("Upload",style: TextStyle(color: Colors.black,fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700),) ,
        icon: Icon(Icons.cloud_upload) ,
        onPressed: startUpload,
      );
    }

  }
}





class VideoUploader extends StatefulWidget {
  final File file;
  VideoUploader({Key key,this.file}) : super(key:key);
  @override
  _VideoUploaderState createState() => _VideoUploaderState();
}

class _VideoUploaderState extends State<VideoUploader> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseStorage _storage=FirebaseStorage(storageBucket: "gs://counsel-c7678.appspot.com");
  StorageUploadTask _task;
  Future<void> startUpload() async {
    setState(() {
      _formKey.currentState.save();
    });
    String filePath='videos/${DateTime.now()}.mp4';
    setState((){
      _task=_storage.ref().child(filePath).putFile(widget.file);
    });
    var dowurl = await (await _task.onComplete).ref.getDownloadURL();
    var url = dowurl.toString();
    print(url);
    Firestore.instance.collection("allvideos").document("${DateTime.now().toIso8601String()}").setData({
      'id':"${DateTime.now().toIso8601String()}",
      'title':currentpost['title'],
      'subpara':currentpost['caption'],
      'postedby':formData['username'],
      'likes':0,
      'link':url
    });
  }
bool emptyfields=false;
  final _titleController=TextEditingController();
  final _captionController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    if(_task!=null){
      return StreamBuilder<StorageTaskEvent>(
        stream: _task.events,
        builder: (context,snapshot){
          var event=snapshot?.data?.snapshot;
          double progressPercent= event !=null ?
          event.bytesTransferred/event.totalByteCount:0;
          return Column(
            children: <Widget>[
              if(_task.isComplete)
                Text("Upload Complete!",style: TextStyle(color: Colors.black,fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700),),
              if(_task.isPaused)
                FloatingActionButton(
                  heroTag: 1,
                  child: Icon(Icons.play_arrow),
                  onPressed: ()=>_task.isInProgress,
                ),
              if(_task.isInProgress)
                FloatingActionButton(
                  heroTag: 2,
                  child: Icon(Icons.pause),
                  onPressed: ()=>_task.isPaused,
                ),
              Center(
                child: Text(
                  "${(progressPercent*100).toStringAsFixed(2)}%",
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white,
                  value:progressPercent,
                ),
              ),],
          );
        },
      );
    }else{
      return Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child:Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: TextFormField(
                      controller: _titleController,
                      style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04,color:Colors.black,fontWeight: FontWeight.w700),
                      onSaved: (var value){
                        setState(() {
                          currentpost['title']=value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Title",
                        contentPadding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 8.0),
                        suffixIcon: !emptyfields ? Icon(Icons.title,color: Colors.black,):Icon(Icons.error,color: Colors.red,),
                        border: InputBorder.none,
                      ),

                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: TextFormField(
                      controller: _captionController,
                      style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04,color:Colors.black,fontWeight: FontWeight.w700),
                      onSaved: (var value){
                        setState(() {
                          currentpost['caption']=value;
                        });
                      },
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Caption",
                        contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                        suffixIcon: !emptyfields ? Icon(Icons.description,color: Colors.black,):Icon(Icons.error,color: Colors.red,),
                        border: InputBorder.none,
                      ),

                    ),
                  ),
                ),
              ],
            ),

          ),
          FlatButton.icon(
            label:Text("Upload",style: TextStyle(color: Colors.black,fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700),) ,
            icon: Icon(Icons.cloud_upload) ,
            onPressed: startUpload,
          ),
        ],
      );
    }

  }
}
