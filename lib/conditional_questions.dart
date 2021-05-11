library conditional_questions;

import 'dart:async';
import 'package:flutter/material.dart';

class Question {
  Question({this.question, this.parent, this.validate})
      : assert(question != null);

  final String question;
  TextEditingController answer;
  Map<Question, String> parent;
  //bool isMandatory;
  final validate;
  bool hasError = false;
  String errorMessage;

  @override
  String toString() {
    // TODO: implement toString
    return question;
  }
}

class PolarQuestion extends Question {
  PolarQuestion(
      {this.question,
      this.answers = const ["Yes", "No"],
      this.parent,
      this.isMandatory = false,
      this.isCheckBox = false})
      : assert(question != null),
        assert(answers != null),
        super(
          question: question,
          parent: parent,
        );
  final List<String> answers;
  final question;
  Map<Question, String> parent;
  final isMandatory;
  final isCheckBox;
  bool hasError = false;
}

class NestedQuestion extends PolarQuestion {
  NestedQuestion(
      {question,
      answers = const ["Yes", "No"],
      children,
      parent,
      isMandatory = false})
      : super(question: question, answers: answers) {
    this.question = question;
    this.answers = answers;
    this.children = children;
    this.parent = parent;
    this.isMandatory = isMandatory;
  }
  String question;
  List<String> answers;
  Map<String, List<Question>> children;

  Map<Question, String> parent;
  bool isMandatory;
  bool hasError = false;
}

class DynamicMCQ {
  Map<String, dynamic> toMap() {
    //print(element.keys.toList()[0].answer);
    Map<String, dynamic> temp = new Map<String, dynamic>();
    expanded.forEach((element) {
      String answer = (!(element.keys.toList()[0] is NestedQuestion ||
              element.keys.toList()[0] is PolarQuestion))
          ? element.keys.toList()[0].answer.text
          : element[element.keys.toList()[0]];
      temp[element.keys.toList()[0].toString()] = answer;
    });
    return temp;
  }

  void setState(Map<String, dynamic> doc) {
    // List<Map<Question, String>> temp = [];
    this.resetState();
    for (int i = 0; i < expanded.length; i++) {
      doc.keys.forEach((field) {
        if (expanded[i].keys.toList()[0].toString() == field) {
          Map<Question, String> temp2 = {};
          if (!(expanded[i].keys.toList()[0] is NestedQuestion ||
              expanded[i].keys.toList()[0] is PolarQuestion))
            expanded[i].keys.toList()[0].answer.text = doc[field];

          //temp2[element.keys.toList()[0]] = doc[field];
          this._onEvent(expanded[i], doc[field]);
          // temp.add(temp2);

          //if nested then
          //temp.add(new Map<Question, dynamic>());
        }
      });
    }
  }

  void dispose() {
    _stream.close();
  }

  void resetState() {
    expanded.clear();
    expanded = _questions.map((e) {
      Map<Question, String> temp = new Map<Question, String>();
      if (!(e is NestedQuestion || e is PolarQuestion))
        e.answer = new TextEditingController();
      temp[e] = null;
      // print(temp.keys);
      return temp;
    }).toList();
    // print("expanded in constructor $expanded");
    _stream.sink.add(expanded);
  }

  final _stream = StreamController<List<Map<Question, String>>>();
  List<Question> _questions;
  List<Map<Question, String>> expanded;
  DynamicMCQ(this._questions) {
    expanded = _questions.map((e) {
      Map<Question, String> temp = new Map<Question, String>();
      if (!(e is NestedQuestion || e is PolarQuestion))
        e.answer = new TextEditingController();
      temp[e] = null;
      print(temp.keys);
      return temp;
    }).toList();
    // print("expanded in constructor $expanded");
    _stream.sink.add(expanded);
  }
  Stream<List<Map<Question, String>>> get stream => _stream.stream;
  // Stream<List<Map<Question, String>>> get _stream.stream;
  void _onEvent(Map<Question, String> questionState, String answer) {
    //print("in onEvent: ${expanded}");
    int location = 0;
    if ((location = expanded.indexOf(questionState)) != -1) {
      expanded[location][questionState.keys.toList()[0]] = answer;

      if (questionState.keys.toList()[0] is PolarQuestion)
        (questionState.keys.toList()[0] as PolarQuestion).hasError = false;

      if (questionState.keys.toList()[0] is NestedQuestion) {
        if (((questionState.keys.toList()[0] as NestedQuestion).children) !=
                null &&
            questionState[questionState.keys.toList()[0]] != null) {
          //  print("Expanding nested question...");
          (questionState.keys.toList()[0] as NestedQuestion)
              .children
              .forEach((key, value) {
            if (key != answer) {
              //     print("ENTERING NO...");
              int count =
                  location + 1; //location value points after nested question
              value.forEach((element) {
                //  print(element.question);
                //  print(count);
                if (count < expanded.length &&
                        expanded[count].containsKey(element) ||
                    count < expanded.length &&
                        expanded[count]
                            .keys
                            .toList()[0]
                            .parent
                            .containsKey(questionState.keys.toList()[0])) {
                  // print("deleting..$count");
                  expanded.removeAt(count);
                }
              });
            }
          });
          for (int i = location + 1; i < expanded.length; i++) {
            if (location + 1 < expanded.length &&
                expanded[location + 1]
                    .keys
                    .toList()[0]
                    .parent
                    .containsKey(questionState.keys.toList()[0])) {
              //  print("deleting..${location + 1}");
              expanded.removeAt(location + 1);
            }
          }
          (questionState.keys.toList()[0] as NestedQuestion)
              .children
              .forEach((key, value) {
            if (key == answer) {
              int count = location + 1;
              value.forEach((element) {
                Map<Question, String> temp = new Map<Question, String>();
                element.parent =
                    expanded[location].keys.toList()[0].parent == null
                        ? expanded[location]
                        : expanded[location].keys.toList()[0].parent;
                if (!(element is NestedQuestion || element is PolarQuestion))
                  element.answer = new TextEditingController();
                temp[element] = null;
                // print("Check this->${element.question} & ${element.answer}");
                // print("temp is $temp");
                expanded.insert(count++, temp);
                //print(expanded);
              });
            }
          });
        }
      }
    }
    _stream.sink.add(expanded);
  }

  bool validate() {
    int count = 0;

    expanded.forEach((element) {
      if (!((element.keys.toList()[0]) is NestedQuestion ||
              (element.keys.toList()[0]) is PolarQuestion) &&
          (element.keys.toList()[0].validate != null &&
              element.keys
                      .toList()[0]
                      .validate(element.keys.toList()[0].answer.text) !=
                  null)) {
        element.keys.toList()[0].errorMessage = element.keys
            .toList()[0]
            .validate(element.keys.toList()[0].answer.text);
        element.keys.toList()[0].hasError = true;
      }

      if (!((element.keys.toList()[0]) is NestedQuestion ||
              (element.keys.toList()[0]) is PolarQuestion) &&
          (element.keys.toList()[0].validate != null &&
              element.keys
                      .toList()[0]
                      .validate(element.keys.toList()[0].answer.text) ==
                  null)) {
        element.keys.toList()[0].errorMessage = null;
        element.keys.toList()[0].hasError = false;
      }

      if (element[element.keys.toList()[0]] == null &&
          element.keys.toList()[0] is PolarQuestion &&
          (element.keys.toList()[0] as PolarQuestion).isMandatory) {
        count++;
        if (element.keys.toList()[0] is PolarQuestion)
          (element.keys.toList()[0] as PolarQuestion).hasError = true;
      }
    });
    if (count > 0)
      return false;
    else
      return true;
  }

  Widget getCard(BuildContext context, Map<dynamic, dynamic> data) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(25, 10, 10, 10),
                  child: /* Text(data.keys.toList()[0].question)*/
                      RichText(
                    text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        text: data.keys.toList()[0].question,
                        children: (!((data.keys.toList()[0])
                                            is NestedQuestion ||
                                        (data.keys.toList()[0])
                                            is PolarQuestion) &&
                                    data.keys.toList()[0].validate != null) ||
                                ((data.keys.toList()[0]) is PolarQuestion &&
                                    data.keys.toList()[0].isMandatory)
                            ? [
                                //check condition before applying star ... start here!
                                TextSpan(
                                    text: "*",
                                    style: TextStyle(color: Colors.red))
                              ]
                            : null),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 25, 8),
                          child: !((data.keys.toList()[0]) is NestedQuestion ||
                                  (data.keys.toList()[0]) is PolarQuestion)
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.4,
                                        child: TextFormField(
                                          maxLines: null,
                                          validator:
                                              data.keys.toList()[0].validate,
                                          controller:
                                              data.keys.toList()[0].answer,
                                          onChanged: (string) {
                                            this._onEvent(data, string);
                                          },
                                        ),
                                      ),
                                      data.keys.toList()[0].hasError
                                          ? Text(
                                              data.keys
                                                  .toList()[0]
                                                  .errorMessage,
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ), //needs fixing and state management of TextEditingControllers
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      direction: Axis.vertical,
                                      children: data.keys
                                          .toList()[0]
                                          .answers
                                          .map<Widget>((answer) {
                                        return CustomRadioButton(
                                          answer: answer,
                                          data: data,
                                          parent: this,
                                        );
                                        /*  return  Row(
                                          //try wrapping this in a stateless/stateful widget with as a validator
                                          children: [
                                            Radio(
                                              value: answer,
                                              groupValue:
                                                  data[data.keys.toList()[0]],
                                              onChanged: (value) {
                                                print(value);

                                                this._onEvent(data, value);
                                              },
                                            ),
                                            Text(answer),
                                          ],
                                        );*/
                                      }).toList(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 0, 0, 0),
                                      child: data.keys.toList()[0].hasError
                                          ? Text(
                                              "This field cannot be empty.",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            )
                                          : Container(),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomRadioButton extends StatelessWidget {
  final answer;
  final data;
  final parent;

  CustomRadioButton({this.answer, this.data, this.parent});

  @override
  Widget build(BuildContext context) {
    return Row(
      //try wrapping this in a stateless/stateful widget with as a validator
      children: [
        Radio(
          value: answer,
          groupValue: data[data.keys.toList()[0]],
          onChanged: (value) {
            print(value);
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            parent._onEvent(data, value);
          },
        ),
        Text(answer),
      ],
    );
  }
}
