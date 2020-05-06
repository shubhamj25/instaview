import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'main.dart';
class CustomAppbar extends StatefulWidget {

  @override
  _CustomAppbarState createState() => _CustomAppbarState();
}
class _CustomAppbarState extends State<CustomAppbar> {
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
    return CurvedNavigationBar(
        backgroundColor: Colors.blueAccent,
        animationCurve: Curves.fastOutSlowIn,
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.search, size: 30),
          Icon(Icons.add, size: 30),
          Icon(Icons.inbox, size: 30),
          Icon(Icons.account_circle, size: 30),
        ],
        onTap: (index) {
          if(index==0){
            Navigator.pop(context);
          }
          if(index==3){
            Navigator.popAndPushNamed(context, '/favourites');
          }
          if(index==4){
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
                                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
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
                                          padding: const EdgeInsets.only(left:30.0,top:20.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Icon(Icons.account_circle,size: 32.0,),
                                                  ),
                                                  Text("Sign Up",style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.w700,color: Colors.blue),),

                                                ],
                                              ),
                                              if (onsignupclick) Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                child: IconButton(
                                                  icon: Icon(Icons.arrow_back,size: 32.0,),
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
                                          padding: const EdgeInsets.only(top:20.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Icon(Icons.vpn_key,size: 30.0,),
                                                  ),
                                                  Text("Login",style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.w700,color: Colors.blue),),
                                                ],
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.close,size: 30.0,),
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
                                              style: TextStyle(fontSize: 20.0,color:Colors.black,fontWeight: FontWeight.w700),
                                              onSaved: (var value){
                                                formData['name']=value.trim();
                                                signupData['name']=value.trim();
                                              },
                                              decoration: InputDecoration(
                                                labelText: "Username",
                                                contentPadding: EdgeInsets.symmetric(horizontal: 28.0,vertical: 10.0),
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
                                                style: TextStyle(fontSize: 20.0,color:Colors.black,fontWeight: FontWeight.w700),
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
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 28.0,vertical: 10.0),
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
                                              style: TextStyle(color:Colors.black,fontSize:20.0,fontWeight: FontWeight.w700),
                                              onSaved: (var value){
                                                formData['password']=value;
                                                signupData['password']=value;
                                              },
                                              obscureText: _obscureText,
                                              decoration: InputDecoration(
                                                labelText: "Password",
                                                contentPadding: EdgeInsets.symmetric(horizontal: 28.0,vertical: 10.0),
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
                                                style: TextStyle(fontSize: 20.0,color:Colors.black,fontWeight: FontWeight.w700),
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
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 28.0,vertical: 10.0),
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
                                                padding: const EdgeInsets.only(right:10.0,top:17.0,bottom:20.0),
                                                child: MaterialButton(
                                                  color: Colors.redAccent,
                                                  elevation: 10.0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal:16.0,vertical:8.0),
                                                    child: Text("Login",style:TextStyle(fontSize: 23.0,fontWeight: FontWeight.w600,color: Colors.white)),
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
                                                padding: const EdgeInsets.only(top:17.0,bottom:20.0,right: 5.0),
                                                child: MaterialButton(
                                                  color:Colors.greenAccent,
                                                  elevation: 10.0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal:16.0,vertical:8.0),
                                                    child: Text("Submit",style:TextStyle(fontSize: 23.0,fontWeight: FontWeight.w600,color: Colors.white)),
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
                                                padding: const EdgeInsets.only(left:5.0,top:17.0,bottom:20.0),
                                                child: MaterialButton(
                                                  color:Colors.blueGrey,
                                                  elevation: 10.0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal:16.0,vertical:8.0),
                                                    child: Text("Return",style:TextStyle(fontSize: 23.0,fontWeight: FontWeight.w600,color: Colors.white)),
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
                                                padding: const EdgeInsets.only(left:10.0,top:17.0,bottom:20.0),
                                                child: MaterialButton(
                                                  color:Colors.lightBlueAccent,
                                                  elevation: 10.0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                                                    child: Text("Signup",style:TextStyle(fontSize: 23.0,fontWeight: FontWeight.w600,color: Colors.white)),
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
                                      Text("Signed in as",style: TextStyle(fontSize: 26.0,fontWeight: FontWeight.w700),textAlign: TextAlign.center,),
                                      Text("${signedin['username']}",style: TextStyle(fontSize: 22.0,color:Colors.blue,fontWeight: FontWeight.w700),textAlign: TextAlign.center),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        MaterialButton(
                                          elevation: 20.0,
                                          color: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("Okay",style: TextStyle(fontSize: 20.0,color: Colors.white,fontWeight: FontWeight.w700),),
                                          ),
                                          onPressed: (){
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
    );
  }
}
