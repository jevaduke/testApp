// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QueryItems? queryItems;
  @override
  void initState() {
    super.initState();
    getQueryItems();
  }

  @override
  Widget build(BuildContext context) {
    return getFutureBuilder();
  }

  List<Widget> getQueryItems() {
    List<Widget> queryWidgets = [];

    List<QueryList> queryList = queryItems?.queryList ?? [];
    QueryList textQueryItems;
    for (textQueryItems in queryList) {
      Widget productQueryItemsWidgets = getQueryCards(
          textQueryItems.queryID,
          textQueryItems.queryText,
          textQueryItems.comments,
          textQueryItems.date,
          textQueryItems.location);
      queryWidgets.add(productQueryItemsWidgets);
    }
    return queryWidgets;
  }

  Widget getQueryCards(
    int queryID,
    String queryText,
    int comments,
    String date,
    String location,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () {},
        child: Container(
          height: 170,
          width: 300,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
                topLeft: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  queryText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Image(
                              image: AssetImage('assets/messenger.png'))),
                      Text(
                        comments.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(date.replaceAll('.', '/')),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  getMainLayout() {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {},
              icon: const Image(
                image: AssetImage('assets/user.png'),
              )),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Image(image: AssetImage('assets/filter.png'))),
            IconButton(
                onPressed: () {},
                icon: const Image(image: AssetImage('assets/search.png'))),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  getHeadingText('My Queries'),
                ],
              ),
              ...getQueryItems(),
            ],
          ),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: 1,
          items: <Widget>[
            IconButton(iconSize: 30, onPressed: () {}, icon: Icon(Icons.home)),
            IconButton(
                iconSize: 30,
                hoverColor: Colors.blue,
                color: Colors.black,
                onPressed: () {},
                icon: Icon(Icons.add)),
            IconButton(
                iconSize: 30, onPressed: () {}, icon: Icon(Icons.message)),
          ],
          onTap: (index) {
            //Handle button tap
          },
        ));
  }

  getResponseFromServer() async {
    var request = http.Request(
        'Get',
        Uri.parse(
            "https://7b799511-b5f4-43fb-ae5d-1f65f67dd8d1.mock.pstmn.io/api/v1/home/feed"));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();

      var jsonParsing = json.decode(responseBody);

      List<QueryList> queryItem = [];
      for (var queries in jsonParsing) {
        QueryList jsonQueryList = QueryList(
            queryID: queries['query_id'],
            queryText: queries['query_text'],
            comments: queries['comments'],
            date: queries['date'],
            location: queries['location']);
        queryItem.add(jsonQueryList);
      }
      queryItems = QueryItems(queryList: queryItem);
      return response;
    } else {
      return Text('no data');
    }
  }

  getFutureBuilder() {
    return FutureBuilder(
        future: getResponseFromServer(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return getCircleProgressIndicator();
          } else {
            return getMainLayout();
          }
        });
  }

  getCircleProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator(),
      ],
    );
  }

  Widget getHeadingText(String text) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class QueryItems {
  List<QueryList> queryList = [];
  QueryItems({
    required this.queryList,
  });
}

class QueryList {
  int queryID;
  String queryText;
  int comments;
  String date;
  String location;
  QueryList({
    required this.queryID,
    required this.queryText,
    required this.comments,
    required this.date,
    required this.location,
  });
}
