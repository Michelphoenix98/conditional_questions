import 'package:conditional_questions/conditional_questions.dart';
import 'package:flutter/material.dart';
import 'package:questionnaire_form/resource.dart';

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
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _key = GlobalKey<QuestionFormState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: ConditionalQuestions(
        key: _key,
        children: questions(),
        trailing: [
          MaterialButton(
            color: Colors.deepOrange,
            splashColor: Colors.orangeAccent,
            onPressed: () async {
              if (_key.currentState!.validate()) {
                print("validated!");
                await (Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                            appBar: AppBar(
                              leading: BackButton(color: Colors.black),
                            ),
                            body: SingleChildScrollView(
                              child: Container(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: _key.currentState!
                                        .getElementList()
                                        .map<Widget>((element) {
                                      return Row(children: [
                                        Text("${element.question}:"),
                                        Text(element.answer == null
                                            ? "null"
                                            : element.answer)
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          )),
                ));
              }
            },
            child: Text("Submit"),
          )
        ],
        leading: [Text("TITLE")],
      ), /*SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: questionManager.getWidget(context),
            ),
            MaterialButton(
              color: Colors.deepOrange,
              splashColor: Colors.orangeAccent,
              onPressed: () async {

                if (questionManager.validate()) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Ok"))
                          ],
                          content:
                        );
                      });
                }
              },
              child: Text("Submit"),
            )
          ],
        ),
      ),*/
    );
  }
}
