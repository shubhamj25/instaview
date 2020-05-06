import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:loading_card/loading_card.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'main.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

List<FavouritesCard> favvideos=[];
class FavScreen extends StatefulWidget {
  @override
  _FavScreenState createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
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
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Raleway',
        accentColor: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body:StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("${signedin['username']}_favourites").snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  favvideos.clear();
                  for(int i=0;i<snapshot.data.documents.length;i++){
                    favvideos.add(FavouritesCard(FavVideoCardDetails.fromSnapshot(snapshot.data.documents[i])));
                  }
                }
                return !snapshot.hasData?Center(child: CircularProgressIndicator()):
                Swiper(
                    containerHeight: MediaQuery.of(context).size.height,
                    itemCount:snapshot.data.documents.length,
                    itemBuilder: (BuildContext context,int index){
                      return Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top:50.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: FloatingActionButton(
                                      backgroundColor: Colors.red,
                                      child: Icon(Icons.favorite,color: Colors.white,)),
                                ),
                                Text("Favourites",style: TextStyle(fontWeight: FontWeight.bold,fontSize:MediaQuery.of(context).size.width*0.08),),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:160.0),
                            child: Swiper(
                              itemBuilder: (BuildContext context,int index){
                                return Stack(
                                  children: <Widget>[
                                      favvideos.elementAt(index),
                                  ],
                                );
                              },
                              itemCount: favvideos.length,
                              layout: SwiperLayout.DEFAULT,
                              itemWidth: 400.0,
                              itemHeight: 300.0,
                              pagination: new SwiperPagination(),
                            ),
                          ),
                        ],
                      );
                    }
                );
              }
          )
      ),
    );
  }
}


class FavVideoCardDetails{
  final String link,title,subpara,postedby,id;
  int likes;
  FavVideoCardDetails.fromMap(Map<dynamic ,dynamic> map)
      : assert(map['link']!=null),
        link=map['link'],
        title=map['title'],
        subpara=map['subpara'],
        id=map['id'],
        postedby=map['postedby'],
        likes=map['likes'];
  FavVideoCardDetails.fromSnapshot(DocumentSnapshot snapshot):this.fromMap(snapshot.data);
}

class FavouritesCard extends StatefulWidget {
  FavVideoCardDetails favVideoCardDetails;
 FavouritesCard(this.favVideoCardDetails);
  @override
  _FavouritesCardState createState() => _FavouritesCardState();
}

class _FavouritesCardState extends State<FavouritesCard> {
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
      Firestore.instance.collection("${signedin['username']}_favourites").document(widget.favVideoCardDetails.title.toString()).get().then((doc){
        if(doc.exists){
          setState(() {
            favourite=true;
          });
        }
      });


    _controller = VideoPlayerController.network(
        widget.favVideoCardDetails.link)
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
        body: _controller.value.initialized
            ?Padding(
              padding: const EdgeInsets.all(13.0),
              child: Stack(
                alignment: Alignment.bottomCenter,
          children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      spreadRadius:2.0,
                      blurRadius: 4.0,
                      offset: Offset(3.0,3.0)
                    )
                  ]
                ),
                width: 400.0,
                height: 350.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: new OverflowBox(
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        alignment: Alignment.center,
                        child: new FittedBox(
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            child: new Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                ),
                                width: _controller.value.size.width,
                                height: _controller.value.size.height,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: <Widget>[
                                    new VideoPlayer(_controller),
                                  ],
                                )
                            )
                        )
                    )
                ),
              ),
              Positioned(
                  bottom:100.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:16.0),
                        child: Text("${widget.favVideoCardDetails.title}",style: TextStyle(fontSize:MediaQuery.of(context).size.width*0.06,fontWeight: FontWeight.w700,color:Colors.white),),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:16.0),
                        child: Text("by ${widget.favVideoCardDetails.postedby}",style: TextStyle(fontSize:MediaQuery.of(context).size.width*0.055,fontWeight: FontWeight.w600,color:Colors.white),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 300.0,
                            maxWidth: 300.0,
                            minHeight: 30.0,
                            maxHeight: 100.0,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal:16.0),
                            child: Text("${widget.favVideoCardDetails.subpara}",style: TextStyle(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w400,color:Colors.white),),
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left:16.0,right: 4.0),
                            child: Icon(Icons.favorite,size: 25.0,color: Colors.white,),
                          ),
                          Text("${widget.favVideoCardDetails.likes}",style: TextStyle(fontSize:MediaQuery.of(context).size.width*0.06,fontWeight: FontWeight.w600,color:Colors.white),),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left:18.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                                                Icon(Icons.edit),
                                                                Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Text("Comments",style:TextStyle(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600)),
                                                                ),
                                                              ],
                                                            ),

                                                            Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: IconButton(
                                                                icon: Icon(Icons.close),
                                                                onPressed: (){
                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            )
                                                          ],
                                                        ),

                                                        Row(
                                                          mainAxisSize: MainAxisSize.max,
                                                          children: <Widget>[
                                                            Material(
                                                              elevation: 12.0,
                                                              color: Colors.white,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                              ),
                                                              child: SizedBox(
                                                                width: MediaQuery.of(context).size.width*0.62,
                                                                child: TextFormField(
                                                                  controller: CommentController,
                                                                  style: TextStyle(fontSize:MediaQuery.of(context).size.width*0.038,color:Colors.black,fontWeight: FontWeight.w700),
                                                                  decoration: InputDecoration(
                                                                    labelText: "Comment",
                                                                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 4.0),
                                                                    suffixIcon: IconButton(icon:Icon(Icons.send,color: Colors.black,),
                                                                      onPressed: (){
                                                                        setState(() {
                                                                          String comment=CommentController.text;
                                                                          Firestore.instance.collection("comments").document('${widget.favVideoCardDetails.id}_comments').get().then((doc){
                                                                            if(doc.exists){
                                                                              Firestore.instance.collection("comments").document('${widget.favVideoCardDetails.id}_comments').updateData({
                                                                                'comments':FieldValue.arrayUnion(['$comment\n~ ${signedin['username']}']),
                                                                              });
                                                                            }
                                                                            else{
                                                                              Firestore.instance.collection("comments").document('${widget.favVideoCardDetails.id}_comments').setData({
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
                                                          ],
                                                        ),

                                                        Container(
                                                          height: 280.0,
                                                          width: 300.0,
                                                          child: StreamBuilder(
                                                              stream: Firestore.instance.collection("comments").document('${widget.favVideoCardDetails.id}_comments').snapshots(),
                                                              builder: (context,snapshot) {
                                                                return !snapshot.hasData? Center(child: CircularProgressIndicator(backgroundColor: Colors.blue,)):
                                                                ListView.builder(
                                                                  itemCount:List.from(snapshot.data['comments']).length ,
                                                                  itemBuilder: (BuildContext context,index){
                                                                    return Comments(List.from(snapshot.data['comments']).elementAt(index));
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
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton(
                              heroTag: Timestamp.now().microsecondsSinceEpoch,
                              backgroundColor:Colors.white,
                              child: Icon(Icons.favorite,color: Colors.red,),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton(
                              heroTag: Timestamp.now().microsecondsSinceEpoch,
                              child: Icon(Icons.share),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton(
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
                          ),
                        ],
                      ),
                    ],
                  )),
              VideoProgressIndicator(_controller, allowScrubbing: true),


          ],
        ),
            )
            : Padding(
              padding: const EdgeInsets.symmetric(horizontal:50.0,vertical:50.0),
              child: JumpingDotsProgressIndicator(color: Colors.black87,fontSize: 120.0,),
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


