import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_questions/conditional_questions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:questionnaire_firestore/resource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('sample')
        .doc('id_1234')
        .get()
        .then((value) {
      if (value.exists) questionManager.setState(value.data());
    });
  }

  DynamicMCQ questionManager = DynamicMCQ(questions());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: questionManager.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text("Loading..."),
                  );
                }
                return Column(
                  children: snapshot.data.map<Widget>((data) {
                    return questionManager.getCard(context, data);
                  }).toList(),
                );
              },
            ),
            MaterialButton(
              color: Colors.deepOrange,
              splashColor: Colors.orangeAccent,
              onPressed: () async {
                //  print("hello");
                if (!questionManager.validate())
                  print("Some of the fields are empty");
                setState(() {
                  FirebaseFirestore.instance
                      .collection('sample')
                      .doc('id_1234')
                      .set(questionManager.toMap());
                });
              },
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
