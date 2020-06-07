import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_manager/constdata.dart';
import 'package:pass_manager/updatepage.dart';

class widgetUI extends StatefulWidget {
  final constdata data;
  widgetUI({this.data});
  @override
  _widgetUIState createState() => _widgetUIState();
}

class _widgetUIState extends State<widgetUI> {

  Future Message_Data_To_Update(var domain, var email, var password, var timestamp) async {
    FlutterSecureStorage store = new FlutterSecureStorage();
    await store.write(key: 'msg-domain', value: '$domain');
    await store.write(key: 'msg-email', value: '$email');
    await store.write(key: 'msg-password', value: '$password');
    await store.write(key: 'msg-timestamp', value: '$timestamp');
  }

  @override
  Widget build(BuildContext context) {
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
                new Text(
                  '${this.widget.data.domain}',
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500),
                ),
                new Padding(
                  padding: new EdgeInsets.all(3.0),
                ),
                new Text(
                  'Email: ${this.widget.data.email}',
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w300),
                ),
                new Padding(
                  padding: new EdgeInsets.all(3.0),
                ),
                new Text(
                  'Password: ${this.widget.data.password}',
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
            new IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => updatedata()));
                Message_Data_To_Update(
                    this.widget.data.domain,
                    this.widget.data.email,
                    this.widget.data.password,
                    this.widget.data.timestamp);
              },
              icon: new Icon(
                Icons.update,
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
