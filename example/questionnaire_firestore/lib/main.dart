import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_questions/conditional_questions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:questionnaire_firestore/resource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _key = GlobalKey<QuestionFormState>();
  late final _firestream;
  @override
  void initState() {
    super.initState();
    _firestream =
        FirebaseFirestore.instance.collection('sample').doc('id_1234').get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return ConditionalQuestions(
            key: _key,
            children: questions(),
            value: snapshot.data!.data(),
            trailing: [
              MaterialButton(
                color: Colors.deepOrange,
                splashColor: Colors.orangeAccent,
                onPressed: () async {
                  if (_key.currentState!.validate()) {
                    print("validated!");
                    FirebaseFirestore.instance
                        .collection('sample')
                        .doc('id_1234')
                        .set(_key.currentState!.toMap());
                  }
                },
                child: Text("Submit"),
              )
            ],
            leading: [Text("TITLE")],
          );
        },
      ),
    );
  }
}
