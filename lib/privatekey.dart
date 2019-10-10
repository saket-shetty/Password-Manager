import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_manager/homepage.dart';


class privatePage extends StatefulWidget {
  @override
  _privatePageState createState() => _privatePageState();
}

class _privatePageState extends State<privatePage> {


  TextEditingController _privateField = new TextEditingController();

  final store = new FlutterSecureStorage();

  Future saveData() async{
    await store.write(key: 'privatekey', value: '${_privateField.text}');
    Navigator.push(context, MaterialPageRoute(builder: (context)=>homepage()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: new AppBar(
        title: new Text('Enter Private Key'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
        child: new Column(
          children: <Widget>[

            new TextFormField(
              controller: _privateField,
              decoration: InputDecoration(hintText: "Enter Email", labelText: "Enter Email"),
              validator: (val) => val.length < 1 ? 'length should be 8' : null,
            ),

            new FlatButton(
              onPressed: (){
                saveData();
              },
              child: new Text('Save'),
            )
          ],
        ),
      ),
      
    );
  }
}