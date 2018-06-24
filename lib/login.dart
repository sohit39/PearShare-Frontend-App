import 'package:flutter/material.dart';

import 'colors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/new-green-hollow-circle.png', width: 250.0, height: 250.0,),
                SizedBox(height: 16.0),
                Text(
                  'PEARSHARE',
                  style: TextStyle(
                    fontFamily: "Raleway",
                    fontSize: 55.0,
                    color: Colors.white
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.0),
            PrimaryColorOverride(
              color: kPearShare,
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            new PrimaryColorOverride(
              color: kPearShare,
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  fillColor: Colors.white
                ),
              ),
            ),
            ButtonBar(
              children: <Widget>[

                FlatButton(
                  child: Text('CANCEL', style: TextStyle(fontFamily: "Raleway2"),),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0)),
                  ),
                  onPressed: () {
                    _usernameController.clear();
                    _passwordController.clear();
                  },
                ),
                new PrimaryColorOverride(color: const Color(0xFF5CDB95),
                child: RaisedButton(
                  child: Text('NEXT' ,style: TextStyle(fontFamily: "Raleway2",color:const Color(0xFF05386B))),
                  elevation: 8.0,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryColorOverride extends StatelessWidget {
  const PrimaryColorOverride({Key key, this.color, this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(primaryColor: color),
    );
  }
}