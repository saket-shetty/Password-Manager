import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:pass_manager/homepage.dart';

class updatedata extends StatefulWidget {
  @override
  _updatedataState createState() => _updatedataState();
}

class _updatedataState extends State<updatedata> {

  //All the textfield controller
  TextEditingController _email = new TextEditingController();
  TextEditingController _password = new TextEditingController();
  TextEditingController _domain = new TextEditingController();

  final store = FlutterSecureStorage();

  var _RETdomain, _RETemail, _RETpassword, _RETtimestamp, _RETuserid;

  var _privateKey, _publicKey;

  DatabaseReference ref = FirebaseDatabase.instance.reference();

  Future getallMsgdata() async{
    _RETdomain = await store.read(key: 'msg-domain');
    _RETemail = await store.read(key: 'msg-email');
    _RETpassword = await store.read(key: 'msg-password');
    _RETtimestamp = await store.read(key: 'msg-timestamp');
    _RETuserid = await store.read(key: 'user-id');

    _privateKey = await store.read(key: 'privatekey');

    ref.child('publickey').once().then((DataSnapshot snap){
      _publicKey = snap.value;
    });

    setState(() {
     _domain.text = _RETdomain;
     _email.text = _RETemail;
     _password.text = _RETpassword; 
    });
  }

  Future Updatedata() async{
    final cryptor = new PlatformStringCryptor();

    final String encryptkey = await cryptor.generateKeyFromPassword(_publicKey, _privateKey);
    final String encryptedDomain = await cryptor.encrypt(_domain.text, encryptkey);
    final String encryptedEmail = await cryptor.encrypt(_email.text, encryptkey);
    final String encryptedPassword = await cryptor.encrypt(_password.text, encryptkey);


    ref.child('$_RETuserid').child('$_RETtimestamp').child('domain').set('${encryptedDomain}');
    ref.child('$_RETuserid').child('$_RETtimestamp').child('email').set('${encryptedEmail}');
    ref.child('$_RETuserid').child('$_RETtimestamp').child('password').set('${encryptedPassword}');

    Navigator.push(context, MaterialPageRoute(builder: (context)=>homepage()));
  }

  @override
  void initState() {
    // TODO: implement initState
    getallMsgdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: new AppBar(
        title: new Text('Updata',
          style: new TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.only(left:8.0, right: 8.0),
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
              padding: new EdgeInsets.all(5.0),
            ),
            new MaterialButton(
              onPressed: (){
                Updatedata();
              },
              child: new Container(
                color: Colors.black,
                width: 100,
                height: 50,
                child: Center(
                  child: new Text(
                    'Update',
                    style: new TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),

    );
  }
}