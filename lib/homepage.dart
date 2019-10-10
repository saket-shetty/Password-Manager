import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pass_manager/login.dart';
import 'package:pass_manager/submitpage.dart';
import 'package:pass_manager/updatepage.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:line_icons/line_icons.dart';


class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {

  final cryptor = new PlatformStringCryptor();

  //constructure variable to store the firebase data
  List<constdata> allData = [];

  //Firebase Database reference
  DatabaseReference ref = FirebaseDatabase.instance.reference();

  //This variable will store the user id 
  var _userid = '';

  //FlutterSecureStore variable
  final FlutterSecureStorage store = new FlutterSecureStorage();


  //This is the main function
  //This will get all the user data and store it into the constructor
  Future get_all_data() async{
    var _privateKey = await store.read(key: 'privatekey');
    var _publicKey;
    ref.child('publickey').once().then((DataSnapshot snap) async{
      _publicKey = await snap.value;
      setState(() async{

        final String encryptkey = await cryptor.generateKeyFromPassword(_publicKey, _privateKey);
        _userid = await store.read(key: 'user-id');
        

        //Here the user id will be retrieved to get the specific user data from the secure store
        if(_userid != null && _publicKey !=null){
          setState(() {

            //Firebase Database code it will give the snapshot of all the timestamp keys of the data
            ref.child('$_userid').once().then((DataSnapshot snap){
              var allkeys = snap.value.keys;
              setState(() {

                //Here the timestamp keys will be itterated and the snapshot of the data is been retrieved in Json format
                for(var x in allkeys){
                  ref.child('$_userid').child(x).once().then((DataSnapshot snap) async{
                    var data = snap.value;
                    var newemail = await cryptor.decrypt(data['email'], encryptkey);
                    var newdomain = await cryptor.decrypt(data['domain'], encryptkey);
                    var newpassword = await cryptor.decrypt(data['password'], encryptkey);
                    constdata newdata = new constdata(
                      newemail,
                      newdomain,
                      newpassword,
                      x
                      );

                    //The Snapshot value is been sotred in the constructor
                    //since we need all the value is single index
                    allData.add(newdata);
                    setState(() {
                      
                    });
                  });
                }
                
              });
            });
          });
        }

        else{
          //If the user id is not retrieved it will call the function again #shittycode
          get_all_data();
        }
      });
    });



 
  }

  @override
  void initState() {
    // TODO: implement initState
    get_all_data();
    super.initState();
  }


  //Code of Google SignOut
  Future Googlesignout() async {
    final GoogleSignIn googleSignIn = new GoogleSignIn(); 
    googleSignIn.signOut();
    await store.deleteAll();
    Navigator.push(context, MaterialPageRoute(builder: (context)=>login()));
  }

  //Code of Facebook SignOut
  Future Twiterlogout() async{
    final facebookLogin = FacebookLogin();
    facebookLogin.logOut();
    await store.deleteAll();
    Navigator.push(context, MaterialPageRoute(builder: (context)=>login()));
  }

  //Here the Data is been transfered to the update page
  Future Message_Data_To_Update(var domain, var email, var password, var timestamp) async{
    await store.write(key: 'msg-domain', value: '$domain');
    await store.write(key: 'msg-email', value: '$email');
    await store.write(key: 'msg-password', value: '$password');
    await store.write(key: 'msg-timestamp', value: '$timestamp');
  }


  Future get_publicKey() async{
    ref.child('publickey').once().then((DataSnapshot snap){
      var key = snap.value;
 
    });
  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: (){
      },

      child: Scaffold(

        appBar: new AppBar(
          title: new Text('Pass Manager',
            style: new TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
          actions: <Widget>[
            new IconButton(
              onPressed: (){  
                Twiterlogout();
                Googlesignout();
              },
              icon: Icon(
                LineIcons.power_off,
                size: 25.0,
              ),
            )
          ],
        ),

        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>submitpage()));
          },
          backgroundColor: Colors.deepPurpleAccent,
        ),
 
        body: allData.length == 0 ? new Text('No Data') : 
        
        new ListView.builder(
          itemCount: allData.length,
          itemBuilder: (_, index){
            return widgetUI(
              allData[index].domain,
              allData[index].email,
              allData[index].password,
              allData[index].timestamp
            );
          }
        ),
      ),
    );
  }

  //listView Widget 
  //It will be created as much as the length of the list
  Widget widgetUI(var domain, var email, var password, var timestamp){
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                new Text('$domain',
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500
                  ),
                ),
                new Padding(
                  padding: new EdgeInsets.all(3.0),
                ),
                new Text('Email: $email',
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w300
                  ),
                ),
                new Padding(
                  padding: new EdgeInsets.all(3.0),
                ),
                new Text('Password: $password',
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w300
                  ),
                ),
              ],
            ),
            new IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>updatedata()));

                Message_Data_To_Update(
                  domain,
                  email,
                  password,
                  timestamp
                );
              },
              icon: new Icon(Icons.update,
                size: 30.0,
                color: Colors.white,
                semanticLabel: 'UPDATE',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Constructor
class constdata{
  var email;
  var password;
  var domain;
  var timestamp;
  constdata(this.email, this.domain, this.password, this.timestamp);
}