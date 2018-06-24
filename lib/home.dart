import 'package:flutter/material.dart';
import 'dart:async';
import 'model/data.dart';
import 'model/product.dart';
import 'supplemental/asymmetric_view.dart';
import 'supplemental/product_card.dart';
import 'dart:collection';
import 'package:http/http.dart' as http;
import 'http_constant.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';
class HomePage extends StatefulWidget {
  Category z = null;
  HomePage(Category cat) {
    z = cat;
  }
  HomePageState createState() {
    return new HomePageState(z);
  }
}

class HomePageState extends State<HomePage> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  static ListQueue<Widget> b = new ListQueue();
  static int currIndex = 0;
  Category category;
  HomePageState (Category a) {
    category = a;
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 1));
    http.get(kBASE_URL + "items/", headers: {'Content-Type': 'application/json'}).then(handleSuccess).catchError(handleFailure);
    return null;
  }
  handleSuccess (http.Response response) {
    print("success");
    var arr = response.body;
    arr = arr.substring(1);
    var objs = arr.split("}");
    for (int i = 0; i < objs.length; i++) {
      objs[i] = objs[i] + "}";
      if (objs[i].startsWith(",")) {
        objs[i] = objs[i].substring(1);
      }
    }
    print(objs.length);
    print(objs);
    print(response.body);


    for(int ind = currIndex; ind < objs.length-1; ind++) {
      JsonDecoder decoder = new JsonDecoder();
      print(objs[ind]);
      Map data = decoder.convert(objs[ind]);
      print(data);
      Product c = Product(category: Category.all, expiry: data["best_before_date"], name: data["title"], price: double.parse(data["price"]).round(), base64: data["image_b64_addr"], id: data["id"] + 999);
      ProductCard card = new ProductCard(product: c);
      updateB(card);
      currIndex = ind+1;
    }


  }
  handleFailure (error) {
    print(error.toString());
  }
  void updateB (ProductCard a) {
    setState(() {
      b.addFirst(a);
    });
  }
  @override
  Widget build(BuildContext context) {
    var a = getProducts(category);
    for (var x = 0; x < a.length; x++) {
      b.add(ProductCard(product: a[x]));
    }
    print(b);
    print(getProducts(category));
    return RefreshIndicator(key: refreshKey, child: new ListView (
        shrinkWrap: true,
        padding: const EdgeInsets.all(20.0),
        children: b.toList()
    ),
      onRefresh: refreshList,);
  }
}