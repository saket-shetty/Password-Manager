import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';

class submitpage extends StatefulWidget {
  @override
  _submitpageState createState() => _submitpageState();
}

class _submitpageState extends State<submitpage> {

  //All the textfield controller
  TextEditingController _email = new TextEditingController();
  TextEditingController _password = new TextEditingController();
  TextEditingController _domain = new TextEditingController();

  //Firebase database reference
  DatabaseReference ref = FirebaseDatabase.instance.reference();

  //Initiallization of the secure store
  final FlutterSecureStorage store = new FlutterSecureStorage();

  var _userid;
  var _publickey;

  var _privateKey;



  //This is the submit form function
  //It will take all the value of the textfield and store it into the firebase database using the timestamp
  Future submitdata() async{
    var time = new DateTime.now();
    final cryptor = new PlatformStringCryptor();

    _privateKey = await store.read(key:'privatekey');

    if(_publickey != null && _publickey != '' && _privateKey != null){
      final String encryptkey = await cryptor.generateKeyFromPassword(_publickey, _privateKey);
      final String encryptedDomain = await cryptor.encrypt(_domain.text, encryptkey);
      final String encryptedEmail = await cryptor.encrypt(_email.text, encryptkey);
      final String encryptedPassword = await cryptor.encrypt(_password.text, encryptkey);

      setState(() {
        if(_domain.text != '' && _email.text != '' && _password.text != '' && _userid != null){
          ref.child('$_userid').child('${time.millisecondsSinceEpoch}').child('domain').set('${encryptedDomain}');
          ref.child('$_userid').child('${time.millisecondsSinceEpoch}').child('email').set('${encryptedEmail}');
          ref.child('$_userid').child('${time.millisecondsSinceEpoch}').child('password').set('${encryptedPassword}');
        }

        ref.child('$_userid').onChildAdded.listen((data){
          var newvalue = data.snapshot.value;
          if(newvalue['email']!=' '){
            _email.clear();
            _domain.clear();
            _password.clear();
          }
        });
      });
    }
  }





  Future get_publicKey() async{
    ref.child('publickey').once().then((DataSnapshot snap){
      var key = snap.value;

      setState(() {
       _publickey = key; 
      });
    });
  }




  //Here the user data is been retrieved
  Future get_user_id() async{
    var userid = await store.read(key: 'user-id');
    setState(() {
     _userid = userid; 
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    get_user_id();
    get_publicKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Submit',
          style: new TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.only(left:15.0, right: 15.0),
        child: new Column(
          children: <Widget>[
            new TextFormField(
              controller: _domain,
              decoration: InputDecoration(hintText: "Domain/link eg:Facebook, Google", labelText: "Enter Domain"),
              validator: (val) => val.length < 1 ? 'Please enter data' : null,
            ),
            new TextFormField(
              controller: _email,
              decoration: InputDecoration(hintText: "Enter Email", labelText: "Enter Email"),
              validator: (val) => val.length < 1 ? 'Please enter data' : null,
            ),
            new TextFormField(
              controller: _password,
              decoration: InputDecoration(hintText: "Enter Password", labelText: "Enter Password"),
              validator: (val) => val.length < 1 ? 'Please enter data' : null,
            ),
            new Padding(
              padding: new EdgeInsets.all(15.0),
            ),
            new MaterialButton(
              onPressed: (){
                submitdata();
              },
              child: new Container(
                color: Colors.black,
                width: 100,
                height: 50,
                child: Center(
                  child: new Text(
                    'Submit',
                    style: new TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}