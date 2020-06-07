import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert' as JSON;

import 'package:flutter_string_encryption/flutter_string_encryption.dart';


class offlinepage extends StatefulWidget {
  @override
  _offlinepageState createState() => _offlinepageState();
}

class _offlinepageState extends State<offlinepage> {

  final store = new FlutterSecureStorage();

  var _data, _datakey;
  var _publicKey, _privateKey;

  final cryptor = new PlatformStringCryptor();

  List<offlinedata> allData = [];


  @override
  void initState() {
    // TODO: implement initState
    get_offline_data();
    super.initState();
  }

  //OFFLINE DATA CODE HERE

  Future get_offline_data() async{
    _data = await store.read(key:'offline-data');
    _datakey = await store.read(key:'offline-key');
    _privateKey = await store.read(key: 'privatekey');
    _publicKey = await store.read(key: 'publickey');

    final String encryptkey = await cryptor.generateKeyFromPassword(_publicKey, _privateKey);
    
    var newdata = JSON.jsonDecode(_data);
    final newkeylist  = JSON.jsonDecode(_datakey);

    for(var x in newkeylist){

      var newemail = await cryptor.decrypt(newdata[x.toString()]['email'], encryptkey);
      var newdomain = await cryptor.decrypt(newdata[x.toString()]['domain'], encryptkey);
      var newpassword = await cryptor.decrypt(newdata[x.toString()]['password'], encryptkey);

      offlinedata constnewdata = new offlinedata(
        newdomain,
        newemail,
        newpassword
      );

      allData.add(constnewdata);
      setState(() {});
    }

    setState(() {
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: new AppBar(
        title: new Text('Offline Page',
          style: new TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),

      body: allData.length == 0 ? new Text('No Data') :  
      new ListView.builder(
        itemCount: allData.length,
        itemBuilder: (_, index){
          return widgetUI(
            allData[index].domain,
            allData[index].email,
            allData[index].password
          );
        }
      ),
    );
  }

  Widget widgetUI(var domain, var email, var password){
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
          ],
        ),
      ),
    );
  }
}

class offlinedata{
  var domain;
  var email;
  var password;

  offlinedata(this.domain, this.email, this.password);
}