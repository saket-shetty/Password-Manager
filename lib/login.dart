import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:line_icons/line_icons.dart';
import 'package:pass_manager/homepage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:pass_manager/offlinepage.dart';
import 'package:pass_manager/privatekey.dart';
import 'package:connectivity/connectivity.dart';

class login extends StatefulWidget {
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {

  // Firebase auth used to show the number of user logged in and using which domain in firebase console 
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Flutter Secure Store is same as the Shared Preference but much faster and store credentials securely
  //It will store the user id and acts as session so that user doesnot have to login again and again
  final FlutterSecureStorage store = new FlutterSecureStorage();

  //Google SignIn starts here
  Future<FirebaseUser> _LoginInGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    var _privatekey = await store.read(key: 'privatekey');


    //Here the credentials have been checked and the user will be displayed in the firebase console.
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //Once the user successfully signedin the user will be Navigated to the homepage
    if(_privatekey !=null){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>homepage()));
    }
    else{
      Navigator.push(context, MaterialPageRoute(builder: (context)=>privatePage()));
    }


    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    //user id is been stored here tocreate a session
    //Also this data is been used to store the user data since Id is unique for everyone.
    await store.write(key: 'user-id', value: '${googleUser.id}');

    return user;
  }
  //Google Signin Ends here

  //Twitter signin starts here
  Future _loginWithFB() async{
    FacebookLogin fbLogin  = new FacebookLogin();

    var _privatekey = await store.read(key: 'privatekey');


    // Open facebook page so that user can login 
    final result = await fbLogin.logInWithReadPermissions(['email', 'public_profile']);

    switch (result.status) {

      //If user successfully loggedin the user data will be returned
      case FacebookLoginStatus.loggedIn:

        //user token will be returned here
        final token = result.accessToken.token;

        //The returned token will be accessed here to get the user data into json format 
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        
        //The json will be decoded here
        final profile = JSON.jsonDecode(graphResponse.body);

        //User profile id will be stored here so that it can be accessd to store the user data 
        await store.write(key: 'user-id', value: '${profile['id']}');

        //navigate to the homepage once the user is authenticated
        if(_privatekey !=null){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>homepage()));
        }
        else{
          Navigator.push(context, MaterialPageRoute(builder: (context)=>privatePage()));
        }
        break;

      case FacebookLoginStatus.cancelledByUser:
        print('some error');
        break;

      case FacebookLoginStatus.error:
        print('some error');
        break;
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    get_user_id();
    super.initState();
  }


  //Here the FlutterSecureStore will check the previously stored id
  //If an id exist it will navigate to the hompage 
  //If no id exist it will stays to the login page
  Future get_user_id() async{
    var connectivityResult = await (Connectivity().checkConnectivity());

    var userid = await store.read(key: 'user-id');
    var _privatekey = await store.read(key: 'privatekey');
    if(userid != null && _privatekey !=null && (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi)){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>homepage()));    
    }
    else if(userid != null && _privatekey !=null && (connectivityResult != ConnectivityResult.mobile || connectivityResult != ConnectivityResult.wifi)){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>offlinepage()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){

      },
      child: Scaffold(
        appBar: new AppBar(
          title: new Text('Login',
            style: new TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),

        body: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              new Icon(
                Icons.lock_outline,
                size: 100.0,
              ),

              new Padding(
                padding: new EdgeInsets.all(10.0),
              ),

              new Container(
                width: MediaQuery.of(context).size.width-200,
                height: 50.0,
                child: new InkWell(
                  onTap: () {
                    _LoginInGoogle();
                  },
                  child: Material(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.redAccent,
                    shadowColor: Colors.redAccent.withOpacity(0.8),
                    elevation: 7.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Icon(
                          LineIcons.google,
                          color: Colors.white,
                        ),
                        new Text(
                          ' | Google',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              new Padding(
                padding: new EdgeInsets.all(10.0),
              ),

              new Container(
                width: MediaQuery.of(context).size.width-200,
                height: 50.0,
                child: new InkWell(
                  onTap: () {
                    _loginWithFB();
                  },
                  child: Material(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.blue[600],
                    shadowColor: Colors.lightBlue.withOpacity(0.8),
                    elevation: 7.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Icon(
                          LineIcons.facebook_official,
                          color: Colors.white,
                        ),
                        new Text(
                          ' | facebook',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}