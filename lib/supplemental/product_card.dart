// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../model/product.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pearshare/http_constant.dart';
import 'package:pearshare/home.dart';

class ProductCard extends StatelessWidget {

  ProductCard({this.imageAspectRatio: 11.5 / 16, this.product})
      : assert(imageAspectRatio == null || imageAspectRatio > 0);

  final double imageAspectRatio;
  final Product product;

  static final kTextBoxHeight = 65.0;
  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        decimalDigits: 0, locale: Localizations.localeOf(context).toString());
    final ThemeData theme = Theme.of(context);
    var fp1 = "";
    var image;
    if (product.base64 != null) {
      print("BASE64: " + product.base64);
      Uint8List bytes = BASE64.decode(product.base64);
      image = new Image.memory(bytes);
    } else {
      print("shit");
      if (product.fp != null) {
        fp1 = product.fp;
      }
      else {
        fp1 = "assets/" + product.id.toString() + "-0.png";
      }
      var assetImage = new AssetImage(fp1);
      image = new Image(image: assetImage);
    }

    var imageWidget = new Container(
      child: new FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => ProductInfo(product)),
          );
        },
        child: new ConstrainedBox(
          constraints: new BoxConstraints.expand(),
          child: image,
        ),
      ),
    );

    return Card( color: Colors.white, elevation: 4.0, margin: EdgeInsets.only(bottom: 10.0), child: Column(

      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
    AspectRatio(
          aspectRatio: imageAspectRatio,
          child: imageWidget,
        ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, size: 55.0,),
            title: Text( product == null ? '' : " " + product.name.toUpperCase(),
            style: TextStyle(color: const Color(0xFF05386B),
                fontSize: 29.0,
                fontFamily: "Raleway3")),
            subtitle:               Text(
              product == null ? '' : " " + formatter.format(product.price),
              style: TextStyle(
                  color: const Color(0xFF05386B),
                  fontSize: 27.0,
                  fontFamily: "Raleway2",
              ),
            ),
          ),
//        AspectRatio(
//          aspectRatio: imageAspectRatio,
//          child: imageWidget,
//        ),
//        SizedBox(
//          height: kTextBoxHeight * MediaQuery.of(context).textScaleFactor,
//          width: 121.0,
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.end,
//            crossAxisAlignment: CrossAxisAlignment.center,
//            children: <Widget>[
//              // TODO(larche): Make headline6 when available
//              Text(
//                product == null ? '' : product.name.toUpperCase(),
//                style: TextStyle(
//                  color: const Color(0xFF05386B),
//                  fontSize: 17.0,
//                  fontFamily: "Raleway3"
//                ),
//                softWrap: false,
//                overflow: TextOverflow.ellipsis,
//                maxLines: 2,
//              ),
//              SizedBox(height: 4.0),
//              // TODO(larche): Make subtitle2 when available
//              Text(
//                product == null ? '' : formatter.format(product.price),
//                style: TextStyle(
//                    color: const Color(0xFF05386B),
//                    fontSize: 17.0,
//                    fontFamily: "Raleway2"
//                ),
//              ),
//              SizedBox(height: 6.0,)
//            ],
//          ),
//        ),
      ],
    ));
  }
}
class ProductInfo extends StatefulWidget {
  Product prod = null;
  ProductInfo(Product p) {
    prod = p;
  }
  ProductInfoState createState() {
    return new ProductInfoState(prod);
  }
}
class ProductInfoState extends State<ProductInfo> {
  bool updatedState = false;
  bool showButton = false;
  bool buttonPressed = false;
  Product prod = null;
  String status = "unsold";
  String deliveryText = "CONFIRM DELIVERY";
  ProductInfoState(Product p) {
    prod = p;
    updatedState = false;
  }
  handleSuccess (http.Response response) {
    print("success2");
    var arr = response.body;
    arr = arr.substring(1);
    var objs = arr.split("}");
    for (int i = 0; i < objs.length; i++) {
      objs[i] = objs[i] + "}";
      if (objs[i].startsWith(",")) {
        objs[i] = objs[i].substring(1);
      }
    }

    for(int ind = 0; ind < objs.length-1; ind++) {

      JsonDecoder decoder = new JsonDecoder();
      Map data = decoder.convert(objs[ind]);
      if (data["id"] + 999 == prod.id) {
        print(data["status"]);
        if (data["status"] == "transacted" && !updatedState) {
          updatedState = true;
          setState(() {
            prod.status = "transacted";
            showButton = true;
          });

        }
      }
    }

  }
  handleFailure(error) {
    print(error.toString());
  }
  void updateProdStatus() {
    http.get(kBASE_URL + "items/", headers: {'Content-Type': 'application/json'}).then(handleSuccess).catchError(handleFailure);
  }
  void callVerif() {
      http.get(kBASE_URL + "twizo/confirm/1");
      setState(() {
        deliveryText = "PENDING";
        buttonPressed = true;
        prod.status = "awaiting verification";
        status = "awaiting verification";
      });
      return null;

  }
  Widget build(BuildContext context) {
    updateProdStatus();
    if (prod.status == "transacted") {
        showButton = true;
        status = "transacted";
    }
    var fp1 = "";
    var image;
    if (prod.base64 != null) {
      print("BASE64: " + prod.base64);
      Uint8List bytes = BASE64.decode(prod.base64);
      image = new Image.memory(bytes);
    } else {
      print("shit2");
      if (prod.fp != null) {
        fp1 = prod.fp;
      }
      else {
        fp1 = "assets/" + prod.id.toString() + "-0.png";
      }
      var assetImage = new AssetImage(fp1);
      image = new Image(image: assetImage);
    }
    var expiry = "12/10/18";
    if (prod.expiry != null) {
      expiry = prod.expiry;
    }
    var _onPressed = null;
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text(prod.name),
        backgroundColor: Colors.blue[900],
      ),
      body: new Column(children: <Widget>[
        new SizedBox(height: 10.0),
        new AspectRatio(aspectRatio: 15/16,
          child: image),
        new SizedBox(height: 3.0),
        new Text(
            prod.name,
            style: TextStyle(
              fontSize: 30.0,
              fontFamily: "Raleway3",
                color: Colors.blue[900]
            )

        ),
        new SizedBox(height: 10.0,),
        new Text("\$" + prod.price.toString(),
            style: TextStyle(
            fontSize: 30.0,
            fontFamily: "Raleway3",
              color: Colors.blue[900]
        )

        ),
        new SizedBox(height: 10.0,),
        new Text(
          "Expiry: " + expiry,
          style: TextStyle(
            color: Colors.blue[900],
            fontSize: 25.0
          ),
        ),
        new SizedBox(height: 5.0,),
        new Text(
          "Status: "  + status,
          style: TextStyle(
              color: const Color(0xFF5CDB95),
              fontSize: 25.0
          ),
        ),
        new SizedBox(height: 5.0,),
        showButton ? new RaisedButton(onPressed: buttonPressed || prod.status == "awaiting verification"? _onPressed : callVerif, child: Text(deliveryText), color: Colors.blue[900], disabledColor: Colors.grey,) : new Container()
        ])
      );
  }
}
