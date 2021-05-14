import 'package:conditional_questions/conditional_questions.dart';
import 'package:flutter/material.dart';
import 'package:questionnaire_app/resource.dart';

void main() {
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
  QuestionHandler questionManager;
  @override
  void initState() {
    super.initState();
    questionManager = QuestionHandler(questions(), callback: update);
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: questionManager.getWidget(context),
            ),
            MaterialButton(
              color: Colors.deepOrange,
              splashColor: Colors.orangeAccent,
              onPressed: () async {
                //  print("hello");
                if (questionManager.validate())
                  print("Some of the fields are empty");
                setState(() {});
              },
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
