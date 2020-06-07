import 'package:flutter/material.dart';
import 'package:pass_manager/constdata.dart';
import 'package:pass_manager/widgetUI.dart';

class searchpage extends StatefulWidget {
  final List<constdata> data;
  searchpage({this.data});
  @override
  _searchpageState createState() => _searchpageState();
}

class _searchpageState extends State<searchpage> {
  TextEditingController searchController = new TextEditingController();
  List<constdata> searchList = [];

  searchFunction() {
    searchList.clear();
    for (constdata data in this.widget.data) {
      if (data.domain
          .toString()
          .toLowerCase()
          .contains(searchController.text)) {
        setState(() {
          searchList.add(data);
        });
      }
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Column(
        children: <Widget>[
          new Container(
            height: MediaQuery.of(context).padding.top,
            color: Colors.deepPurpleAccent,
          ),
          new Container(
            color: Colors.deepPurpleAccent,
            width: MediaQuery.of(context).size.width,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  width: MediaQuery.of(context).size.width - 50,
                  height: 40.0,
                  child: new TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: searchController,
                    style: new TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: new TextStyle(color: Colors.white),
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    ),
                  ),
                ),
                new IconButton(
                  icon: new Icon(
                    Icons.search,
                    size: 30.0,
                  ),
                  color: Colors.white,
                  onPressed: searchFunction,
                )
              ],
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              removeTop: true,
                          context: context,
                          child: ListView.builder(
                  itemCount: searchList.length,
                  itemBuilder: (_, index) {
                    return widgetUI(data: searchList[index]);
                  }),
            ),
          )
        ],
      ),
    );
  }
}
