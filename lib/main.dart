

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:share/share.dart';
import 'package:tictok/favoirites.dart';
import 'package:video_player/video_player.dart';
import 'camera.dart';
import 'customshape.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';


Future<void> main() async{
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name:'railyatri-firestore',
    options: Platform.isIOS
            ? const FirebaseOptions(
        googleAppID: "1:1038388826547:ios:872e1275a63bf40288fbc6",
        gcmSenderID: "1038388826547",
        databaseURL: "https://counsel-c7678.firebaseio.com/"

          )
            :const FirebaseOptions(
        googleAppID: '1:1038388826547:android:26e52b3be26fc6df88fbc6',
        apiKey: "AIzaSyDOkUABZF_0Zzc3i-fl3exp_SLuPTQdxLM",
        databaseURL: "https://counsel-c7678.firebaseio.com/"
  ));
  cameras = await availableCameras();
  runApp(
    MaterialApp(
      title: "RailYatri App",
      debugShowCheckedModeBanner: false,
      home: MyBottomNavigationBar(),
      routes: <String, WidgetBuilder> {
        '/home': (BuildContext context) => new MyBottomNavigationBar(),
        '/favourites':(BuildContext context) => new FavScreen(),
      },
      theme: ThemeData(
        fontFamily: 'Raleway',
        primaryColor: Colors.pink,
        accentColor: Colors.blue,
      ),
    )
  );

}
List<CameraDescription> cameras = [];
Map<String, dynamic> formData = {'name': null, 'password': null};
Map<String, dynamic> signupData = {'name':null,'email': null, 'password': null,'address':null,'phone':null};
Map<String, dynamic> signedin = {'username': null};
List<VideoApp> videos=[];

bool  closingloggingalert=false;
class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _formKey = GlobalKey<FormState>();
  final searchFieldController=TextEditingController();
  final phoneFieldController=TextEditingController();
  bool _obscureText = true;
  bool onsignupclick=false;
  bool onsubmit=false;
  double signupfieldopac=0.0;
  String status="You are not Signed In";
  bool signupvalidation=false;
  bool signinerror=false;
  bool loading=false;
  bool phonesignup=false;
  bool requestingotp=false;
  bool phoneregistered=true;
  bool _autoValidate = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("allvideos").snapshots(),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                videos.clear();
                for(int i=0;i<snapshot.data.documents.length;i++){
                  videos.add(VideoApp(VideoCardDetails.fromSnapshot(snapshot.data.documents[i])));
                }
              }
              return !snapshot.hasData?Center(child: CircularProgressIndicator()):Swiper(
              containerHeight: MediaQuery.of(context).size.height,
              itemCount:snapshot.data.documents.length,
              itemBuilder: (BuildContext context,int index){
                return Stack(
                  children: <Widget>[
                    videos.elementAt(index),
                  ],
                );
              }
              );
            }
          )
    );
  }
}

List<Comments> comments=[];
class VideoCardDetails{
  final String link,title,subpara,postedby,id;
  int likes;
  VideoCardDetails.fromMap(Map<dynamic ,dynamic> map)
      : assert(map['link']!=null),
        link=map['link'],
        title=map['title'],
        subpara=map['subpara'],
        id=map['id'],
        postedby=map['postedby'],
        likes=map['likes'];
  VideoCardDetails.fromSnapshot(DocumentSnapshot snapshot):this.fromMap(snapshot.data);
}
void share(BuildContext context,VideoCardDetails videoCardDetails){
  final RenderBox box=context.findRenderObject();
  final String text="Hey there Checkout this Post by ${videoCardDetails.postedby}\n${videoCardDetails.title}\nLink to Video:\n${videoCardDetails.link}";
  Share.share(text,
      subject: videoCardDetails.subpara,
      sharePositionOrigin:box.localToGlobal(Offset.zero) & box.size);
}


class VideoApp extends StatefulWidget {
  VideoCardDetails videoCardDetails;
  VideoApp(this.videoCardDetails);
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;
  final CommentController=TextEditingController();
  bool favourite=false;
  final _formKey = GlobalKey<FormState>();
  final searchFieldController=TextEditingController();
  final phoneFieldController=TextEditingController();
  bool _obscureText = true;
  bool onsignupclick=false;
  bool onsubmit=false;
  double signupfieldopac=0.0;
  String status="You are not Signed In";
  bool signupvalidation=false;
  bool signinerror=false;
  bool loading=false;
  bool phonesignup=false;
  bool requestingotp=false;
  bool phoneregistered=true;
  bool _autoValidate = false;
  @override
  void initState() {
    super.initState();
    if(signedin['username']!=null)
      Firestore.instance.collection("${signedin['username']}_favourites").document(widget.videoCardDetails.title.toString()).get().then((doc){
        if(doc.exists){
          setState(() {
            favourite=true;
          });
        }
      });
    _controller = VideoPlayerController.network(
        widget.videoCardDetails.link)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: _controller.value.initialized
              ?Stack(
                alignment: Alignment.bottomLeft,
                children: <Widget>[
                  ClipRect(
                  child: new OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      alignment: Alignment.center,
                      child: new FittedBox(
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          child: new Container(
                              width: _controller.value.size.width,
                              height: _controller.value.size.height,
                              child: new VideoPlayer(_controller)
                          )
                      )
                  )
          ),
                  Positioned(
                    bottom:100.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:16.0),
                            child: Text("${widget.videoCardDetails.title}",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w700,color:Colors.white),),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:16.0),
                            child: Text("by ${widget.videoCardDetails.postedby}",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.052,fontWeight: FontWeight.w600,color:Colors.white),),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:16.0),
                            child: Container(
                              width: 350.0,
                                child: Text("${widget.videoCardDetails.subpara}",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w400,color:Colors.white),)),
                          ),
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left:16.0,right: 4.0),
                                child: Icon(Icons.favorite,size: 25.0,color: Colors.white,),
                              ),
                              Text("${widget.videoCardDetails.likes}",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.052,fontWeight: FontWeight.w600,color:Colors.white),),
                            ],
                          ),
                        ],
                      )),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              )
              : Center(child:   CollectionScaleTransition(
            children: <Widget>[
              Icon(Icons.fiber_manual_record,color: Colors.red,),
              Icon(Icons.fiber_manual_record,color: Colors.blue,),
              Icon(Icons.fiber_manual_record,color: Colors.yellow,),
              Icon(Icons.fiber_manual_record,color: Colors.green,),
            ],
          ),),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left:18.0),
              child: FloatingActionButton(
                heroTag: Timestamp.now().microsecondsSinceEpoch,
                child: Icon(Icons.comment),
                onPressed: () {
                  showDialog (
                    context:context,
                    builder:(context) {
                      return StatefulBuilder(
                          builder: (context, setState) {
                            return SingleChildScrollView(
                              child: AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                content: Container(
                                  height: 400.0,
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Icon(Icons.edit,size: 20.0),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text("Comments",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600)),
                                              ),
                                            ],
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: IconButton(
                                              icon: Icon(Icons.close,size: 20.0,),
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                            ),
                                          )
                                        ],
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                                        child: Material(
                                          elevation: 12.0,
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          ),
                                          child: SizedBox(
                                            width: 230.0,
                                            child: TextFormField(
                                              controller: CommentController,
                                              style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                              decoration: InputDecoration(
                                                labelText: "Comment",
                                                contentPadding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 4.0),
                                                suffixIcon: IconButton(icon:Icon(Icons.send,color: Colors.black,),
                                                  onPressed: (){
                                                    setState(() {
                                                      String comment=CommentController.text;
                                                      Firestore.instance.collection("comments").document('${widget.videoCardDetails.id}_comments').get().then((doc){
                                                        if(doc.exists){
                                                          Firestore.instance.collection("comments").document('${widget.videoCardDetails.id}_comments').updateData({
                                                            'comments':FieldValue.arrayUnion(['$comment\n~ ${signedin['username']}']),
                                                          });
                                                        }
                                                        else{
                                                          Firestore.instance.collection("comments").document('${widget.videoCardDetails.id}_comments').setData({
                                                            'comments':FieldValue.arrayUnion(['$comment\n~ ${signedin['username']}']),
                                                          });
                                                        }
                                                      });
                                                      CommentController.clear();
                                                    });
                                                  },),
                                                border: InputBorder.none,
                                              ),

                                            ),
                                          ),
                                        ),
                                      ),

                                      Container(
                                        height: 280.0,
                                        width: 300.0,
                                        child: StreamBuilder(
                                          stream: Firestore.instance.collection("comments").document('${widget.videoCardDetails.id}_comments').snapshots(),
                                          builder: (context,snapshot) {
                                            return !snapshot.hasData? Center(child: CircularProgressIndicator(backgroundColor: Colors.blue,)):
                                            ListView.builder(
                                              itemCount:List.from(snapshot.data['comments']).length ,
                                              itemBuilder: (BuildContext context,index){
                                                return Comments(List.from(snapshot.data['comments']).reversed.elementAt(index));
                                              },
                                            );
                                          }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ),
                            );
                          }
                      );
                    },
                  );
                }
              ),
            ),

            FloatingActionButton(
              heroTag: Timestamp.now().microsecondsSinceEpoch,
                  backgroundColor: favourite? Colors.white:Colors.blue,
                  child: !favourite?Icon(Icons.favorite):Icon(Icons.favorite,color: Colors.red,),
                  onPressed: () {
                    setState(() {
                      if(signedin['username']!=null){
                        if(favourite==false){
                          favourite=true;
                          widget.videoCardDetails.likes++;
                          Firestore.instance.collection("allvideos").document(widget.videoCardDetails.id.toString()).updateData({
                            'likes':widget.videoCardDetails.likes,
                          });
                          Firestore.instance.collection('${signedin['username']}_favourites').document("${widget.videoCardDetails.title}").setData({
                            'title':widget.videoCardDetails.title,
                            'postedby':widget.videoCardDetails.postedby,
                            'link':widget.videoCardDetails.link,
                            'id':widget.videoCardDetails.id,
                            'subpara':widget.videoCardDetails.subpara,
                            'likes':widget.videoCardDetails.likes
                          });
                        }
                        else if(favourite==true){
                          favourite=false;
                          widget.videoCardDetails.likes--;
                          Firestore.instance.collection("allvideos").document(widget.videoCardDetails.id.toString()).updateData({
                            'likes':widget.videoCardDetails.likes,
                          });
                          Firestore.instance.collection('${signedin['username']}_favourites').document("${widget.videoCardDetails.title}").delete();
                        }
                      }
                     else{
                        showDialog(
                            context:context,
                            builder:(context)
                            {
                              return StatefulBuilder(
                                  builder: (context, setState) {
                                    return SingleChildScrollView(
                                      child: AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                        content: Column(
                                          children: <Widget>[
                                            if(loading)LinearProgressIndicator(),
                                            Form(
                                              key:_formKey,
                                              autovalidate: _autoValidate,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  onsignupclick ?Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Icon(Icons.account_circle,size: 25.0,),
                                                            ),
                                                            Text("Sign Up",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w700,color: Colors.blue),),

                                                          ],
                                                        ),
                                                        if (onsignupclick) Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: IconButton(
                                                            icon: Icon(Icons.arrow_back,size: 25.0,),
                                                            onPressed: (){
                                                              setState(() {
                                                                onsignupclick=false;
                                                                onsubmit=false;
                                                              });
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ):Padding(
                                                    padding: const EdgeInsets.only(top:8.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Icon(Icons.vpn_key,size: 25.0,),
                                                            ),
                                                            Text("Login",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w700,color: Colors.blue),),
                                                          ],
                                                        ),
                                                        IconButton(
                                                          icon: Icon(Icons.close,size: 25.0,),
                                                          onPressed:() {
                                                            Navigator.pop(context);
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),


                                                  Padding(
                                                    padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                                                    child: Material(
                                                      elevation: 5.0,
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                      child: TextFormField(
                                                        style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                                        onSaved: (var value){
                                                          formData['name']=value.trim();
                                                          signupData['name']=value.trim();
                                                        },
                                                        decoration: InputDecoration(

                                                          labelText: "Username",
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                          suffixIcon: !signinerror ? Icon(Icons.person,color: Colors.black,):Icon(Icons.error,color: Colors.red,),
                                                          border: InputBorder.none,
                                                        ),

                                                      ),
                                                    ),
                                                  ),

                                                  if(onsignupclick)AnimatedOpacity(
                                                    opacity: signupfieldopac,
                                                    duration: Duration(seconds: 1),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                                                      child: Material(
                                                        elevation: 5.0,
                                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                        child: TextFormField(
                                                          style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                                          controller: searchFieldController,
                                                          onSaved: (var value){
                                                            signupData['email']=value.trim();
                                                          },
                                                          validator:(String value){
                                                            Pattern pattern =
                                                                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                                            RegExp regex = new RegExp(pattern);
                                                            if (!regex.hasMatch(value)) {
                                                              status="Invalid Email Address";signupvalidation=false;
                                                            }
                                                            else{
                                                              signupvalidation=true;
                                                            }
                                                            return null;
                                                          },
                                                          decoration: InputDecoration(
                                                            labelText: "Email",
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                            suffixIcon: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Icon(Icons.email,color: Colors.black,),
                                                            ),
                                                            border: InputBorder.none,
                                                          ),


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
                                                        style: TextStyle(color:Colors.black,fontSize:18.0,fontWeight: FontWeight.w700),
                                                        onSaved: (var value){
                                                          formData['password']=value;
                                                          signupData['password']=value;
                                                        },
                                                        obscureText: _obscureText,
                                                        decoration: InputDecoration(
                                                          labelText: "Password",
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                          suffixIcon: !signinerror ? IconButton(icon:_obscureText ? Icon(Icons.lock,color: Colors.black,size: 28.0,):
                                                          Icon(Icons.lock_open,color: Colors.black,size: 28.0,),
                                                            onPressed: (){
                                                              setState(() {
                                                                if(_obscureText==true) _obscureText=false;
                                                                else  if(_obscureText==false) _obscureText=true;
                                                              });
                                                            },):
                                                          Icon(Icons.error,color: Colors.red,),
                                                          border: InputBorder.none,
                                                        ),

                                                      ),
                                                    ),
                                                  ),

                                                  if(onsignupclick)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                                                      child: Material(
                                                        elevation: 5.0,
                                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                        child: TextFormField(
                                                          style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                                          onSaved: (var value){
                                                            signupData['phone']=value;
                                                          },
                                                          validator:(String value){
                                                            if (value.trim().length!=13) {
                                                              status="Invalid Phone Number";signupvalidation=false;
                                                            }
                                                            else{
                                                              signupvalidation=true;
                                                            }
                                                            return null;
                                                          },
                                                          keyboardType: TextInputType.phone,
                                                          decoration: InputDecoration(
                                                            labelText: "Mobile",
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                            suffixIcon: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Icon(Icons.phone,color: Colors.black,),
                                                            ),
                                                            border: InputBorder.none,
                                                          ),

                                                        ),
                                                      ),
                                                    ),

                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      if(onsubmit==false)
                                                        Padding(
                                                          padding: const EdgeInsets.only(right:8.0,top:15.0,bottom:8.0),
                                                          child: MaterialButton(
                                                            color: Colors.redAccent,
                                                            elevation: 10.0,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                              child: Text("Login",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                            ),
                                                            onPressed: (){
                                                              setState(() {
                                                                _formKey.currentState.save();
                                                                signinerror=false;
                                                                loading=true;
                                                                Firestore.instance.collection('users').document(formData['name']).get().then((snapshot) {
                                                                  if(snapshot.exists && formData['name']==snapshot.data['name'] && formData['password']==snapshot.data['password']){
                                                                    setState(() {
                                                                      closingloggingalert=true;
                                                                      signedin["username"]=snapshot.data['name'];
                                                                      Navigator.pushReplacementNamed(context,'/home');
                                                                    });
                                                                  }
                                                                  else{
                                                                    setState(() {
                                                                      signinerror=true;
                                                                    });
                                                                  }
                                                                });
                                                              });
                                                            },
                                                          ),
                                                        ),

                                                      if(onsubmit==true)
                                                        Padding(
                                                          padding: const EdgeInsets.only(top:15.0,bottom:8.0,right: 5.0),
                                                          child: MaterialButton(
                                                            color:Colors.greenAccent,
                                                            elevation: 10.0,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                              child: Text("Submit",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                            ),
                                                            onPressed: (){
                                                              setState(() {
                                                                _formKey.currentState.validate();
                                                                if (signupvalidation) {
                                                                  _formKey.currentState.save();
                                                                  loading=true;
                                                                  print(signupData);
                                                                  Firestore.instance.collection('users').document(signupData['name']).setData({
                                                                    'name':signupData['name'],
                                                                    'email':signupData['email'],
                                                                    'password':signupData['password'],
                                                                    'phone':signupData['phone']
                                                                  });
                                                                  Firestore.instance.collection('regphones').document("${signupData['phone']}").setData({
                                                                    'phone_number': signupData['phone'],
                                                                  });
                                                                  signupfieldopac=0.0;
                                                                  onsignupclick=false;
                                                                  onsubmit=false;
                                                                }
                                                                else {
                                                                  setState(() {
                                                                    _autoValidate = true;
                                                                    loading=true;
                                                                  });
                                                                }

                                                              });
                                                            },
                                                          ),
                                                        ),

                                                      if(onsignupclick)
                                                        Padding(
                                                          padding: const EdgeInsets.only(right:5.0,top:15.0,bottom:8.0),
                                                          child: MaterialButton(
                                                            color:Colors.blueGrey,
                                                            elevation: 10.0,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                              child: Text("Return",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                            ),
                                                            onPressed: (){
                                                              setState(() {
                                                                onsignupclick=false;
                                                                onsubmit=false;
                                                              });
                                                            },
                                                          ),
                                                        ),

                                                      if(onsubmit==false)
                                                        Padding(
                                                          padding: const EdgeInsets.only(top:15.0,bottom:8.0),
                                                          child: MaterialButton(
                                                            color:Colors.lightBlueAccent,
                                                            elevation: 10.0,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                              child: Text("Signup",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                            ),
                                                            onPressed: (){
                                                              setState(() {
                                                                signupfieldopac=1.0;
                                                                onsignupclick=true;
                                                                onsubmit=true;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                              );
                            }
                        );
                      }
                    });
                },
                ),

            FloatingActionButton(
              heroTag: Timestamp.now().microsecondsSinceEpoch,
              child: Icon(Icons.share),
             onPressed: ()=> share(context,widget.videoCardDetails),
            ),

            FloatingActionButton(
              heroTag: Timestamp.now().microsecondsSinceEpoch,
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}


class Comments extends StatefulWidget {
  String comment;
  Comments(this.comment);
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(child: Text("${widget.comment}",style: TextStyle(color:Colors.white,fontSize: MediaQuery.of(context).size.width*0.045,fontWeight:FontWeight.w500),textAlign: TextAlign.left,)),
            ],
          ),
        ),);
  }
}

class MyBottomNavigationBar extends StatefulWidget {
  final List<CameraDescription> cameras;
  MyBottomNavigationBar({this.cameras});
  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  final _formKey = GlobalKey<FormState>();
  final searchFieldController=TextEditingController();
  final phoneFieldController=TextEditingController();
  bool _obscureText = true;
  bool onsignupclick=false;
  bool onsubmit=false;
  double signupfieldopac=0.0;
  String status="You are not Signed In";
  bool signupvalidation=false;
  bool signinerror=false;
  bool loading=false;
  bool phonesignup=false;
  bool requestingotp=false;
  bool phoneregistered=true;
  bool _autoValidate = false;
  List<Widget> _children=[
    Homepage(),
    FavScreen(),
    ImageCapture(),
  ];
  int _currentIndex=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:_children[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.blueAccent,
          animationCurve: Curves.fastOutSlowIn,
          items: <Widget>[
            Icon(Icons.home, size: 30),
            Icon(Icons.add, size: 30),
            Icon(Icons.inbox, size: 30),
            Icon(Icons.account_circle, size: 30),
          ],
          onTap: (index) {
            if(index==1){
              if(signedin['username']==null) {
                showDialog(
                    context:context,
                    builder:(context)
                    {
                      return StatefulBuilder(
                          builder: (context, setState) {
                            return SingleChildScrollView(
                              child: AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                content: Column(
                                  children: <Widget>[
                                    if(loading)LinearProgressIndicator(),
                                    Form(
                                      key:_formKey,
                                      autovalidate: _autoValidate,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          onsignupclick ?Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(Icons.account_circle,size: 25.0,),
                                                    ),
                                                    Text("Sign Up",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w700,color: Colors.blue),),

                                                  ],
                                                ),
                                                if (onsignupclick) Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: IconButton(
                                                    icon: Icon(Icons.arrow_back,size: 25.0,),
                                                    onPressed: (){
                                                      setState(() {
                                                        onsignupclick=false;
                                                        onsubmit=false;
                                                      });
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ):Padding(
                                            padding: const EdgeInsets.only(top:8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(Icons.vpn_key,size: 25.0,),
                                                    ),
                                                    Text("Login",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w700,color: Colors.blue),),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.close,size: 25.0,),
                                                  onPressed:() {
                                                    Navigator.pop(context);
                                                  },
                                                )
                                              ],
                                            ),
                                          ),


                                          Padding(
                                            padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                                            child: Material(
                                              elevation: 5.0,
                                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                              child: TextFormField(
                                                style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                                onSaved: (var value){
                                                  formData['name']=value.trim();
                                                  signupData['name']=value.trim();
                                                },
                                                decoration: InputDecoration(
                                                  labelText: "Username",
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                  suffixIcon: !signinerror ? Icon(Icons.person,color: Colors.black,):Icon(Icons.error,color: Colors.red,),
                                                  border: InputBorder.none,
                                                ),

                                              ),
                                            ),
                                          ),

                                          if(onsignupclick)AnimatedOpacity(
                                            opacity: signupfieldopac,
                                            duration: Duration(seconds: 1),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                                              child: Material(
                                                elevation: 5.0,
                                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                child: TextFormField(
                                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                                  controller: searchFieldController,
                                                  onSaved: (var value){
                                                    signupData['email']=value.trim();
                                                  },
                                                  validator:(String value){
                                                    Pattern pattern =
                                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                                    RegExp regex = new RegExp(pattern);
                                                    if (!regex.hasMatch(value)) {
                                                      status="Invalid Email Address";signupvalidation=false;
                                                    }
                                                    else{
                                                      signupvalidation=true;
                                                    }
                                                    return null;
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: "Email",
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                    suffixIcon: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(Icons.email,color: Colors.black,),
                                                    ),
                                                    border: InputBorder.none,
                                                  ),


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
                                                style: TextStyle(color:Colors.black,fontSize:18.0,fontWeight: FontWeight.w700),
                                                onSaved: (var value){
                                                  formData['password']=value;
                                                  signupData['password']=value;
                                                },
                                                obscureText: _obscureText,
                                                decoration: InputDecoration(
                                                  labelText: "Password",
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                  suffixIcon: !signinerror ? IconButton(icon:_obscureText ? Icon(Icons.lock,color: Colors.black,size: 28.0,):
                                                  Icon(Icons.lock_open,color: Colors.black,size: 28.0,),
                                                    onPressed: (){
                                                      setState(() {
                                                        if(_obscureText==true) _obscureText=false;
                                                        else  if(_obscureText==false) _obscureText=true;
                                                      });
                                                    },):
                                                  Icon(Icons.error,color: Colors.red,),
                                                  border: InputBorder.none,
                                                ),

                                              ),
                                            ),
                                          ),

                                          if(onsignupclick)
                                            Padding(
                                              padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                                              child: Material(
                                                elevation: 5.0,
                                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                child: TextFormField(
                                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                                  onSaved: (var value){
                                                    signupData['phone']=value;
                                                  },
                                                  validator:(String value){
                                                    if (value.trim().length!=13) {
                                                      status="Invalid Phone Number";signupvalidation=false;
                                                    }
                                                    else{
                                                      signupvalidation=true;
                                                    }
                                                    return null;
                                                  },
                                                  keyboardType: TextInputType.phone,
                                                  decoration: InputDecoration(
                                                    labelText: "Mobile",
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                    suffixIcon: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(Icons.phone,color: Colors.black,),
                                                    ),
                                                    border: InputBorder.none,
                                                  ),

                                                ),
                                              ),
                                            ),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              if(onsubmit==false)
                                                Padding(
                                                  padding: const EdgeInsets.only(right:8.0,top:15.0,bottom:8.0),
                                                  child: MaterialButton(
                                                    color: Colors.redAccent,
                                                    elevation: 10.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                      child: Text("Login",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                    ),
                                                    onPressed: (){
                                                      setState(() {
                                                        _formKey.currentState.save();
                                                        signinerror=false;
                                                        loading=true;
                                                        Firestore.instance.collection('users').document(formData['name']).get().then((snapshot) {
                                                          if(snapshot.exists && formData['name']==snapshot.data['name'] && formData['password']==snapshot.data['password']){
                                                            setState(() {
                                                              closingloggingalert=true;
                                                              signedin["username"]=snapshot.data['name'];
                                                              Navigator.pushReplacementNamed(context,'/home');
                                                            });
                                                          }
                                                          else{
                                                            setState(() {
                                                              signinerror=true;
                                                            });
                                                          }
                                                        });
                                                      });
                                                    },
                                                  ),
                                                ),

                                              if(onsubmit==true)
                                                Padding(
                                                  padding: const EdgeInsets.only(top:15.0,bottom:8.0,right: 5.0),
                                                  child: MaterialButton(
                                                    color:Colors.greenAccent,
                                                    elevation: 10.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                      child: Text("Submit",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                    ),
                                                    onPressed: (){
                                                      setState(() {
                                                        _formKey.currentState.validate();
                                                        if (signupvalidation) {
                                                          _formKey.currentState.save();
                                                          loading=true;
                                                          print(signupData);
                                                          Firestore.instance.collection('users').document(signupData['name']).setData({
                                                            'name':signupData['name'],
                                                            'email':signupData['email'],
                                                            'password':signupData['password'],
                                                            'phone':signupData['phone']
                                                          });
                                                          Firestore.instance.collection('regphones').document("${signupData['phone']}").setData({
                                                            'phone_number': signupData['phone'],
                                                          });
                                                          signupfieldopac=0.0;
                                                          onsignupclick=false;
                                                          onsubmit=false;
                                                        }
                                                        else {
                                                          setState(() {
                                                            _autoValidate = true;
                                                            loading=true;
                                                          });
                                                        }

                                                      });
                                                    },
                                                  ),
                                                ),

                                              if(onsignupclick)
                                                Padding(
                                                  padding: const EdgeInsets.only(right:5.0,top:15.0,bottom:8.0),
                                                  child: MaterialButton(
                                                    color:Colors.blueGrey,
                                                    elevation: 10.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                      child: Text("Return",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                    ),
                                                    onPressed: (){
                                                      setState(() {
                                                        onsignupclick=false;
                                                        onsubmit=false;
                                                      });
                                                    },
                                                  ),
                                                ),

                                              if(onsubmit==false)
                                                Padding(
                                                  padding: const EdgeInsets.only(top:15.0,bottom:8.0),
                                                  child: MaterialButton(
                                                    color:Colors.lightBlueAccent,
                                                    elevation: 10.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                      child: Text("Signup",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                    ),
                                                    onPressed: (){
                                                      setState(() {
                                                        signupfieldopac=1.0;
                                                        onsignupclick=true;
                                                        onsubmit=true;
                                                      });
                                                    },
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      );
                    }
                );
              }else{
                setState(() {
                  _currentIndex=2;
                });
              }
            }
            if(index==0){
              setState(() {
                _currentIndex=0;
              });
            }
            if(index==2){
              if(signedin['username']==null){
                showDialog(
                    context:context,
                    builder:(context)
                    {
                      return StatefulBuilder(
                          builder: (context, setState) {
                            return SingleChildScrollView(
                              child: AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                content: Column(
                                  children: <Widget>[
                                    if(loading)LinearProgressIndicator(),
                                    Form(
                                      key:_formKey,
                                      autovalidate: _autoValidate,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          onsignupclick ?Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(Icons.account_circle,size: 25.0,),
                                                    ),
                                                    Text("Sign Up",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w700,color: Colors.blue),),

                                                  ],
                                                ),
                                                if (onsignupclick) Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: IconButton(
                                                    icon: Icon(Icons.arrow_back,size: 25.0,),
                                                    onPressed: (){
                                                      setState(() {
                                                        onsignupclick=false;
                                                        onsubmit=false;
                                                      });
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ):Padding(
                                            padding: const EdgeInsets.only(top:8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(Icons.vpn_key,size: 25.0,),
                                                    ),
                                                    Text("Login",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w700,color: Colors.blue),),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.close,size: 25.0,),
                                                  onPressed:() {
                                                    Navigator.pop(context);
                                                  },
                                                )
                                              ],
                                            ),
                                          ),


                                          Padding(
                                            padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                                            child: Material(
                                              elevation: 5.0,
                                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                              child: TextFormField(
                                                style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                                onSaved: (var value){
                                                  formData['name']=value.trim();
                                                  signupData['name']=value.trim();
                                                },
                                                decoration: InputDecoration(
                                                  labelText: "Username",
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                  suffixIcon: !signinerror ? Icon(Icons.person,color: Colors.black,):Icon(Icons.error,color: Colors.red,),
                                                  border: InputBorder.none,
                                                ),

                                              ),
                                            ),
                                          ),

                                          if(onsignupclick)AnimatedOpacity(
                                            opacity: signupfieldopac,
                                            duration: Duration(seconds: 1),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                                              child: Material(
                                                elevation: 5.0,
                                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                child: TextFormField(
                                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                                  controller: searchFieldController,
                                                  onSaved: (var value){
                                                    signupData['email']=value.trim();
                                                  },
                                                  validator:(String value){
                                                    Pattern pattern =
                                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                                    RegExp regex = new RegExp(pattern);
                                                    if (!regex.hasMatch(value)) {
                                                      status="Invalid Email Address";signupvalidation=false;
                                                    }
                                                    else{
                                                      signupvalidation=true;
                                                    }
                                                    return null;
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: "Email",
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                    suffixIcon: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(Icons.email,color: Colors.black,),
                                                    ),
                                                    border: InputBorder.none,
                                                  ),


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
                                                style: TextStyle(color:Colors.black,fontSize:18.0,fontWeight: FontWeight.w700),
                                                onSaved: (var value){
                                                  formData['password']=value;
                                                  signupData['password']=value;
                                                },
                                                obscureText: _obscureText,
                                                decoration: InputDecoration(
                                                  labelText: "Password",
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                  suffixIcon: !signinerror ? IconButton(icon:_obscureText ? Icon(Icons.lock,color: Colors.black,size: 28.0,):
                                                  Icon(Icons.lock_open,color: Colors.black,size: 28.0,),
                                                    onPressed: (){
                                                      setState(() {
                                                        if(_obscureText==true) _obscureText=false;
                                                        else  if(_obscureText==false) _obscureText=true;
                                                      });
                                                    },):
                                                  Icon(Icons.error,color: Colors.red,),
                                                  border: InputBorder.none,
                                                ),

                                              ),
                                            ),
                                          ),

                                          if(onsignupclick)
                                            Padding(
                                              padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                                              child: Material(
                                                elevation: 5.0,
                                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                child: TextFormField(
                                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                                  onSaved: (var value){
                                                    signupData['phone']=value;
                                                  },
                                                  validator:(String value){
                                                    if (value.trim().length!=13) {
                                                      status="Invalid Phone Number";signupvalidation=false;
                                                    }
                                                    else{
                                                      signupvalidation=true;
                                                    }
                                                    return null;
                                                  },
                                                  keyboardType: TextInputType.phone,
                                                  decoration: InputDecoration(
                                                    labelText: "Mobile",
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                    suffixIcon: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(Icons.phone,color: Colors.black,),
                                                    ),
                                                    border: InputBorder.none,
                                                  ),

                                                ),
                                              ),
                                            ),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              if(onsubmit==false)
                                                Padding(
                                                  padding: const EdgeInsets.only(right:8.0,top:15.0,bottom:8.0),
                                                  child: MaterialButton(
                                                    color: Colors.redAccent,
                                                    elevation: 10.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                      child: Text("Login",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                    ),
                                                    onPressed: (){
                                                      setState(() {
                                                        _formKey.currentState.save();
                                                        signinerror=false;
                                                        loading=true;
                                                        Firestore.instance.collection('users').document(formData['name']).get().then((snapshot) {
                                                          if(snapshot.exists && formData['name']==snapshot.data['name'] && formData['password']==snapshot.data['password']){
                                                            setState(() {
                                                              closingloggingalert=true;
                                                              signedin["username"]=snapshot.data['name'];
                                                              Navigator.pushReplacementNamed(context,'/home');
                                                            });
                                                          }
                                                          else{
                                                            setState(() {
                                                              signinerror=true;
                                                            });
                                                          }
                                                        });
                                                      });
                                                    },
                                                  ),
                                                ),

                                              if(onsubmit==true)
                                                Padding(
                                                  padding: const EdgeInsets.only(top:15.0,bottom:8.0,right: 5.0),
                                                  child: MaterialButton(
                                                    color:Colors.greenAccent,
                                                    elevation: 10.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                      child: Text("Submit",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                    ),
                                                    onPressed: (){
                                                      setState(() {
                                                        _formKey.currentState.validate();
                                                        if (signupvalidation) {
                                                          _formKey.currentState.save();
                                                          loading=true;
                                                          print(signupData);
                                                          Firestore.instance.collection('users').document(signupData['name']).setData({
                                                            'name':signupData['name'],
                                                            'email':signupData['email'],
                                                            'password':signupData['password'],
                                                            'phone':signupData['phone']
                                                          });
                                                          Firestore.instance.collection('regphones').document("${signupData['phone']}").setData({
                                                            'phone_number': signupData['phone'],
                                                          });
                                                          signupfieldopac=0.0;
                                                          onsignupclick=false;
                                                          onsubmit=false;
                                                        }
                                                        else {
                                                          setState(() {
                                                            _autoValidate = true;
                                                            loading=true;
                                                          });
                                                        }

                                                      });
                                                    },
                                                  ),
                                                ),

                                              if(onsignupclick)
                                                Padding(
                                                  padding: const EdgeInsets.only(right:5.0,top:15.0,bottom:8.0),
                                                  child: MaterialButton(
                                                    color:Colors.blueGrey,
                                                    elevation: 10.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                      child: Text("Return",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                    ),
                                                    onPressed: (){
                                                      setState(() {
                                                        onsignupclick=false;
                                                        onsubmit=false;
                                                      });
                                                    },
                                                  ),
                                                ),

                                              if(onsubmit==false)
                                                Padding(
                                                  padding: const EdgeInsets.only(top:15.0,bottom:8.0),
                                                  child: MaterialButton(
                                                    color:Colors.lightBlueAccent,
                                                    elevation: 10.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                      child: Text("Signup",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                    ),
                                                    onPressed: (){
                                                      setState(() {
                                                        signupfieldopac=1.0;
                                                        onsignupclick=true;
                                                        onsubmit=true;
                                                      });
                                                    },
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      );
                    }
                );
              }
              else{
                //Navigator.popAndPushNamed(context, '/favourites');
                setState(() {
                  _currentIndex=1;
                });
              }
            }
            if(index==3){
              if(signedin['username']==null) {
                showDialog(
                    context:context,
                    builder:(context)
                    {
                      return StatefulBuilder(
                          builder: (context, setState) {
                            return SingleChildScrollView(
                              child: AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                content: Column(
                                  children: <Widget>[
                                    if(loading)LinearProgressIndicator(),
                                    Form(
                                      key:_formKey,
                                      autovalidate: _autoValidate,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          onsignupclick ?Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(Icons.account_circle,size: 25.0,),
                                                    ),
                                                    Text("Sign Up",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w700,color: Colors.blue),),

                                                  ],
                                                ),
                                                if (onsignupclick) Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: IconButton(
                                                    icon: Icon(Icons.arrow_back,size: 25.0,),
                                                    onPressed: (){
                                                      setState(() {
                                                        onsignupclick=false;
                                                        onsubmit=false;
                                                      });
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ):Padding(
                                            padding: const EdgeInsets.only(top:8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(Icons.vpn_key,size: 25.0,),
                                                    ),
                                                    Text("Login",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w700,color: Colors.blue),),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.close,size: 25.0,),
                                                  onPressed:() {
                                                    Navigator.pop(context);
                                                  },
                                                )
                                              ],
                                            ),
                                          ),


                                          Padding(
                                            padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                                            child: Material(
                                              elevation: 5.0,
                                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                              child: TextFormField(
                                                style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                                onSaved: (var value){
                                                  formData['name']=value.trim();
                                                  signupData['name']=value.trim();
                                                },
                                                decoration: InputDecoration(
                                                  labelText: "Username",
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                  suffixIcon: !signinerror ? Icon(Icons.person,color: Colors.black,):Icon(Icons.error,color: Colors.red,),
                                                  border: InputBorder.none,
                                                ),

                                              ),
                                            ),
                                          ),

                                          if(onsignupclick)AnimatedOpacity(
                                            opacity: signupfieldopac,
                                            duration: Duration(seconds: 1),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                                              child: Material(
                                                elevation: 5.0,
                                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                child: TextFormField(
                                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                                  controller: searchFieldController,
                                                  onSaved: (var value){
                                                    signupData['email']=value.trim();
                                                  },
                                                  validator:(String value){
                                                    Pattern pattern =
                                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                                    RegExp regex = new RegExp(pattern);
                                                    if (!regex.hasMatch(value)) {
                                                      status="Invalid Email Address";signupvalidation=false;
                                                    }
                                                    else{
                                                      signupvalidation=true;
                                                    }
                                                    return null;
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: "Email",
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                    suffixIcon: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(Icons.email,color: Colors.black,),
                                                    ),
                                                    border: InputBorder.none,
                                                  ),


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
                                                style: TextStyle(color:Colors.black,fontSize:18.0,fontWeight: FontWeight.w700),
                                                onSaved: (var value){
                                                  formData['password']=value;
                                                  signupData['password']=value;
                                                },
                                                obscureText: _obscureText,
                                                decoration: InputDecoration(
                                                  labelText: "Password",
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                  suffixIcon: !signinerror ? IconButton(icon:_obscureText ? Icon(Icons.lock,color: Colors.black,size: 28.0,):
                                                  Icon(Icons.lock_open,color: Colors.black,size: 28.0,),
                                                    onPressed: (){
                                                      setState(() {
                                                        if(_obscureText==true) _obscureText=false;
                                                        else  if(_obscureText==false) _obscureText=true;
                                                      });
                                                    },):
                                                  Icon(Icons.error,color: Colors.red,),
                                                  border: InputBorder.none,
                                                ),

                                              ),
                                            ),
                                          ),

                                          if(onsignupclick)
                                            Padding(
                                              padding: const EdgeInsets.only(top:9.0,bottom:5.0),
                                              child: Material(
                                                elevation: 5.0,
                                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                child: TextFormField(
                                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                                  onSaved: (var value){
                                                    signupData['phone']=value;
                                                  },
                                                  validator:(String value){
                                                    if (value.trim().length!=13) {
                                                      status="Invalid Phone Number";signupvalidation=false;
                                                    }
                                                    else{
                                                      signupvalidation=true;
                                                    }
                                                    return null;
                                                  },
                                                  keyboardType: TextInputType.phone,
                                                  decoration: InputDecoration(
                                                    labelText: "Mobile",
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                                                    suffixIcon: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Icon(Icons.phone,color: Colors.black,),
                                                    ),
                                                    border: InputBorder.none,
                                                  ),

                                                ),
                                              ),
                                            ),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              if(onsubmit==false)
                                                Padding(
                                                  padding: const EdgeInsets.only(right:8.0,top:15.0,bottom:8.0),
                                                  child: MaterialButton(
                                                    color: Colors.redAccent,
                                                    elevation: 10.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                      child: Text("Login",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                    ),
                                                    onPressed: (){
                                                      setState(() {
                                                        _formKey.currentState.save();
                                                        signinerror=false;
                                                        loading=true;
                                                        Firestore.instance.collection('users').document(formData['name']).get().then((snapshot) {
                                                          if(snapshot.exists && formData['name']==snapshot.data['name'] && formData['password']==snapshot.data['password']){
                                                            setState(() {
                                                              closingloggingalert=true;
                                                              signedin["username"]=snapshot.data['name'];
                                                              Navigator.pushReplacementNamed(context,'/home');
                                                            });
                                                          }
                                                          else{
                                                            setState(() {
                                                              signinerror=true;
                                                            });
                                                          }
                                                        });
                                                      });
                                                    },
                                                  ),
                                                ),

                                              if(onsubmit==true)
                                                Padding(
                                                  padding: const EdgeInsets.only(top:15.0,bottom:8.0,right: 5.0),
                                                  child: MaterialButton(
                                                    color:Colors.greenAccent,
                                                    elevation: 10.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                      child: Text("Submit",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                    ),
                                                    onPressed: (){
                                                      setState(() {
                                                        _formKey.currentState.validate();
                                                        if (signupvalidation) {
                                                          _formKey.currentState.save();
                                                          loading=true;
                                                          print(signupData);
                                                          Firestore.instance.collection('users').document(signupData['name']).setData({
                                                            'name':signupData['name'],
                                                            'email':signupData['email'],
                                                            'password':signupData['password'],
                                                            'phone':signupData['phone']
                                                          });
                                                          Firestore.instance.collection('regphones').document("${signupData['phone']}").setData({
                                                            'phone_number': signupData['phone'],
                                                          });
                                                          signupfieldopac=0.0;
                                                          onsignupclick=false;
                                                          onsubmit=false;
                                                        }
                                                        else {
                                                          setState(() {
                                                            _autoValidate = true;
                                                            loading=true;
                                                          });
                                                        }

                                                      });
                                                    },
                                                  ),
                                                ),

                                              if(onsignupclick)
                                                Padding(
                                                  padding: const EdgeInsets.only(right:5.0,top:15.0,bottom:8.0),
                                                  child: MaterialButton(
                                                    color:Colors.blueGrey,
                                                    elevation: 10.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                      child: Text("Return",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                    ),
                                                    onPressed: (){
                                                      setState(() {
                                                        onsignupclick=false;
                                                        onsubmit=false;
                                                      });
                                                    },
                                                  ),
                                                ),

                                              if(onsubmit==false)
                                                Padding(
                                                  padding: const EdgeInsets.only(top:15.0,bottom:8.0),
                                                  child: MaterialButton(
                                                    color:Colors.lightBlueAccent,
                                                    elevation: 10.0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                      child: Text("Signup",style:TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.white)),
                                                    ),
                                                    onPressed: (){
                                                      setState(() {
                                                        signupfieldopac=1.0;
                                                        onsignupclick=true;
                                                        onsubmit=true;
                                                      });
                                                    },
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      );
                    }
                );
              }
              else{
                showDialog(
                    context:context,
                    builder:(context)
                    {
                      return StatefulBuilder(
                          builder: (context, setState) {
                            return SingleChildScrollView(
                              child: AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Icon(Icons.account_circle,size: 50.0,color: Colors.blueAccent,),
                                    Column(
                                      children: <Widget>[
                                        Text("Signed in as",style: TextStyle(fontSize:MediaQuery.of(context).size.width*0.058,fontWeight: FontWeight.w700),textAlign: TextAlign.center,),
                                        Text("${signedin['username']}",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.051,color:Colors.blue,fontWeight: FontWeight.w700),textAlign: TextAlign.center),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          MaterialButton(
                                            elevation: 20.0,
                                            color: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text("Okay",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,color: Colors.white,fontWeight: FontWeight.w700),),
                                            ),
                                            onPressed: (){
                                              Navigator.pop(context);
                                            },
                                          ),
                                          MaterialButton(
                                            elevation: 20.0,
                                            color: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text("Logout",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,color: Colors.white,fontWeight: FontWeight.w700),),
                                            ),
                                            onPressed: (){
                                              signedin['username']=null;
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                      );
                    }
                );
              }
            }
          }
      ),
    );
  }
}
