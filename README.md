# conditional_questions
[![Pub Version](https://img.shields.io/pub/v/conditional_questions.svg?style=flat-square)](https://pub.dev/packages/conditional_questions)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

A package that handles the creation and state of a dynamic questionnaire/survey with conditional questions.
Have you ever wanted to implement a form/questionnaire/survey like the ones you see on Google forms?
Have you ever wanted to implement conditional questions that show or hide the questions that follow, based on the user's input?
All you need to do is frame the questions in a specific way and the package handles the widget creation
and the state management for you.


<img src="https://user-images.githubusercontent.com/40787439/117844127-0f39fc00-b29d-11eb-9bb3-714ba2b58811.gif" alt="Screenrecorder-2021-05-11-20-23-21-153" width="200"/>


## Installation

This project requires the latest version of [Dart](https://www.dartlang.org/). You can download the latest and greatest [here](https://www.dartlang.org/tools/sdk#install).

### 1. Depend on it

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
    conditional_questions: '^1.0.4'
```


#### 2. Install it

You can install packages from the command line:

```bash
$ pub get
..
```

Alternatively, your editor might support pub. Check the docs for your editor to learn more.

#### 3. Import it

Now in your Dart code, you can use:

```Dart
import 'package:conditional_questions/conditional_questions.dart';
```

## Usage

First, you must initialize the question structure where you specify the type of questions
and their possible answers, if any. You can also nest questions to form conditional questions.
You can even mark them as mandatory.

There are three types of questions.
 ### Questions 
 This is an instance of a regular question 
 where the answer is not limited to any specific choice.
 The answer to this question can be typed in by the user, single line or multiline.
 ```Dart
 Question(
  question: "What is your name?",
  validate:(field){
     if (field.isEmpty) return "Field cannot be empty";
          return null;
             }
         )
 ```
### PolarQuestions
This is an instance of a Closed-Ended question where the answer is limited to a set of pre-defined choices.
The answer list provided to this instance is rendered as a set of Radio buttons.
   ```Dart  
      PolarQuestion(
          question: "Have you made any donations in the past?",
          answers: ["Yes", "No"],
          isMandatory: true,
                   )
   ```     
 ### NestedQuestions
 This is an instance of a Closed-Ended question where the answer is limited to a set of pre-defined choices.
 But they are slightly different from PolarQuestions. They can hold or 'nest' other questions.
 The nested questions or the children are associated to a particular answer of the parent question.
 They are dynamically shown depending on the selected choice.
 ```Dart
  NestedQuestion(
        question: "The series will depend on your answer",
        answers: ["Yes", "No"],
        children: {
          'Yes': [
            PolarQuestion(
                question: "Have you ever taken medication for H1n1?",
                answers: ["Yes", "No"]),
            PolarQuestion(
                question: "Have you ever taken medication for Rabies?",
                answers: ["Yes", "No"]),
            Question(
              question: "Comments",
            ),
          ],
          'No': [
            NestedQuestion(
                question: "Have you sustained any injuries?",
                answers: [
                  "Yes",
                  "No"
                ],
                children: {
                  'Yes': [
                    PolarQuestion(
                        question: "Did it result in a disability?",
                        answers: ["Yes", "No", "I prefer not to say"]),
                  ],
                  'No': [
                    PolarQuestion(
                        question:
                            "Have you ever been infected with chicken pox?",
                        answers: ["Yes", "No"]),
                  ]
                }),
          ],
        },
      )
 ```
### A full question structure represented as a List:
```Dart

  List<Question> questions() {
    return [
      Question(
        question: "What is your name?",
        //isMandatory: true,
        validate: (field) {
          if (field.isEmpty) return "Field cannot be empty";
          return null;
        },
      ),
      PolarQuestion(
          question: "Have you made any donations in the past?",
          answers: ["Yes", "No"],
          isMandatory: true),
      PolarQuestion(
          question: "In the last 3 months have you had a vaccination?",
          answers: ["Yes", "No"]),
      PolarQuestion(
          question: "Have you ever taken medication for HIV?",
          answers: ["Yes", "No"]),
      NestedQuestion(
        question: "The series will depend on your answer",
        answers: ["Yes", "No"],
        children: {
          'Yes': [
            PolarQuestion(
                question: "Have you ever taken medication for H1n1?",
                answers: ["Yes", "No"]),
            PolarQuestion(
                question: "Have you ever taken medication for Rabies?",
                answers: ["Yes", "No"]),
            Question(
              question: "Comments",
            ),
          ],
          'No': [
            NestedQuestion(
                question: "Have you sustained any injuries?",
                answers: [
                  "Yes",
                  "No"
                ],
                children: {
                  'Yes': [
                    PolarQuestion(
                        question: "Did it result in a disability?",
                        answers: ["Yes", "No", "I prefer not to say"]),
                  ],
                  'No': [
                    PolarQuestion(
                        question:
                            "Have you ever been infected with chicken pox?",
                        answers: ["Yes", "No"]),
                  ]
                }),
          ],
        },
      )
    ];
  }
```
### Initialize an instance of QuestionHandler
This is the main class that manages the state of the questions.
```Dart
  QuestionHandler questionManager;
  @override
  void initState() {
    super.initState();
    questionManager = QuestionHandler(questions(), callback: update);
  }

  void update() {
    setState(() {});
  }
```
### Pass the context to getWidget()
An instance of the QuestionHandler class contains a getWidget() method that returns a
list of widgets that represent question cards. Remember, it returns a list of widgets.
```Dart
SingleChildScrollView(
        child: Column(
          children: [

            Column(
              children: questionManager.getWidget(context),
            ),
            MaterialButton(
              color: Colors.deepOrange,
              splashColor: Colors.orangeAccent,
              onPressed: () async {
                if (questionManager.validate())
                  print("Some of the fields are empty");
                setState(() {});
              },
              child: Text("Submit"),
            )
          ],
        ),
      ),
```
## Full code:
```Dart
import 'package:conditional_questions/conditional_questions.dart';
import 'package:flutter/material.dart';

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
List<Question> questions() {
  return [
    Question(
      question: "What is your name?",
      //isMandatory: true,
      validate: (field) {
        if (field.isEmpty) return "Field cannot be empty";
        return null;
      },
    ),
    PolarQuestion(
        question: "Have you made any donations in the past?",
        answers: ["Yes", "No"],
        isMandatory: true),
    PolarQuestion(
        question: "In the last 3 months have you had a vaccination?",
        answers: ["Yes", "No"]),
    PolarQuestion(
        question: "Have you ever taken medication for HIV?",
        answers: ["Yes", "No"]),
    NestedQuestion(
      question: "The series will depend on your answer",
      answers: ["Yes", "No"],
      children: {
        'Yes': [
          PolarQuestion(
              question: "Have you ever taken medication for H1n1?",
              answers: ["Yes", "No"]),
          PolarQuestion(
              question: "Have you ever taken medication for Rabies?",
              answers: ["Yes", "No"]),
          Question(
            question: "Comments",
          ),
        ],
        'No': [
          NestedQuestion(
              question: "Have you sustained any injuries?",
              answers: [
                "Yes",
                "No"
              ],
              children: {
                'Yes': [
                  PolarQuestion(
                      question: "Did it result in a disability?",
                      answers: ["Yes", "No", "I prefer not to say"]),
                ],
                'No': [
                  PolarQuestion(
                      question: "Have you ever been infected with chicken pox?",
                      answers: ["Yes", "No"]),
                ]
              }),
        ],
      },
    )
  ];
}
```

## Support
This happens to be my very first dart package that's been published,
your support would really cheer me up and help me become a better developer.

<a href="https://www.buymeacoffee.com/michelthomas98" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>
