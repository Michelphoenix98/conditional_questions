# conditional_questions

A dynamic questionnaire/survey handling  package.




<img src="https://user-images.githubusercontent.com/40787439/117844127-0f39fc00-b29d-11eb-9bb3-714ba2b58811.gif" alt="Screenrecorder-2021-05-11-20-23-21-153" width="200"/>


## Installation

This project requires the latest version of [Dart](https://www.dartlang.org/). You can download the latest and greatest [here](https://www.dartlang.org/tools/sdk#install).

### 1. Depend on it

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
    conditional_questions: '^0.0.1'
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
### Initialize an instance of DynamicMCQ
This is the main class that manages the state of the questions.
```Dart
  DynamicMCQ questionManager;
  @override
  void initState() {
    super.initState();
    questionManager = DynamicMCQ(questions());
  }
```
### Access the stream and render the widgets
An instance of the DynamicMCQ class contains a stream that contains the state of the questions.
The stream provides us with a List of Maps.
Invoke the getCard() function of the instance of class DynamicMCQ and pass a Map one at a time from the List(snapshot) to the getCard() function
to render all the questions as widget cards.

```Dart
SingleChildScrollView(
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
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DynamicMCQ questionManager;
  @override
  void initState() {
    super.initState();
    questionManager = DynamicMCQ(questions());
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
                setState(() {});
              },
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
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
}
```

## Tips

You can also use this repo as a template for creating Dart packages, just clone the repo and start hacking :) 
