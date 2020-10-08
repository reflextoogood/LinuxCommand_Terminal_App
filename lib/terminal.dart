import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Terminal extends StatefulWidget {
  @override
  _TerminalState createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  var fordatabase = FirebaseFirestore.instance;
  var authentication = FirebaseAuth.instance;
  var webdata;
  var cmd;
  var finaldata;
  var finaldata1;
  call() async {
    try {
      var url = "http://192.168.0.192/cgi-bin/linux.py?x=${cmd}";
      var r = await http.get(url);
      webdata = r.body;
      await fordatabase.collection("LinuxData").add({
        "$cmd": webdata,
        "cmd": "$cmd",
        "output": webdata,
      });
      var d = await fordatabase.collection("LinuxData").get();
      for (var i in d.docs) {
        print(i.data());
        finaldata = i.data();
        setState(() {
          if (finaldata['cmd'] == "$cmd") {
            finaldata1 = finaldata['output'];
          }
        });
      }
    } catch (ex) {
      print(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffec0101),
        title: Text("Terminal"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              print("user is now signed off");
              await authentication.signOut();
              Navigator.pop(context);
            }),
        actions: [
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                print("user is now signed off");
                await authentication.signOut();
                Navigator.pop(context);
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/redhat3.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "RUN YOUR LINUX COMMANDS",
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          onChanged: (value) {
                            cmd = value;
                          },
                          autocorrect: false,
                          style: TextStyle(color: Colors.white, fontSize: 18.0),
                          cursorColor: Colors.white,
                          cursorWidth: 4.0,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              hintText: "Run your command",
                              helperText: 'Enter ur command',
                              helperStyle: TextStyle(color: Colors.white),
                              hintStyle: TextStyle(
                                  fontSize: 19.0, color: Colors.white),
                              prefixIcon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  "  [root@localhost ~]#  ",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ))),
                    ),
                    MaterialButton(
                      elevation: 5.0,
                      height: 35,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      color: Color(0xFFff4b5c),
                      onPressed: () {
                        call();
                      },
                      child: Text("RUN"),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      width: 400.0,
                      height: 370.0,
                      color: Colors.black.withOpacity(0.5),
                      child: ListView.builder(
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int i) {
                          return Center(
                            child: Text(
                              finaldata1 ?? "Output is almost here",
                              style: TextStyle(
                                  fontSize: 22.0, color: Colors.white),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
