import 'package:conditional_questions/conditional_questions.dart';

///A class to create and manage the state of the questions.
///
/// accepts a parameter of type List<Question>, which is a list of [Question] objects
/// that specifies the structure of the questionnaire.
class QuestionHandler {
  ///This method returns a Map<String,String> object of the
  ///current state of the question cards.
  ///This format is useful for writing to a database eg Firestore.
  Map<String, dynamic> toMap() {
    Map<String, dynamic> temp = new Map<String, dynamic>();
    expanded.forEach((element) {
      String? answer = (!(element.keys.toList()[0] is NestedQuestion ||
              element.keys.toList()[0] is PolarQuestion))
          ? element.keys.toList()[0].answer.text
          : element[element.keys.toList()[0]];
      temp[element.keys.toList()[0].toString()] = answer;
    });
    return temp;
  }

  List<FormElement> getElementList() {
    List<FormElement> temp = [];
    expanded.forEach((element) {
      String? answer = (!(element.keys.toList()[0] is NestedQuestion ||
              element.keys.toList()[0] is PolarQuestion))
          ? element.keys.toList()[0].answer.text
          : element[element.keys.toList()[0]];
      temp.add(FormElement(
          question: element.keys.toList()[0].toString(), answer: answer));
    });
    return temp;
  }

  ///This method is used to set the state of the cards containing the questions and answers.
  ///
  /// It accepts a parameter [doc] of type Map<String,String> which essentially contains
  /// an unordered list of question:answer key:value pairs typically fetched from a database.
  /// This method sets the state and arranges the questions according to the order
  /// specified by the [_questionStructure] variable.
  void setState(Map<String, dynamic> doc) {
    this.resetState();
    for (int i = 0; i < expanded.length; i++) {
      doc.keys.forEach((field) {
        if (expanded[i].keys.toList()[0].toString() == field) {
          if (!(expanded[i].keys.toList()[0] is NestedQuestion ||
              expanded[i].keys.toList()[0] is PolarQuestion))
            expanded[i].keys.toList()[0].answer.text = doc[field];

          this._onEvent(expanded[i], doc[field]);
        }
      });
    }
  }

  /*void dispose() {
    _stream.close();
  }*/

  ///The resetState() method is, as its name implies,
  ///used to revert the states of all the cards back to its
  ///default state(null).
  void resetState() {
    expanded.clear();
    expanded = _questionStructure.map((e) {
      Map<Question, String?> temp = new Map<Question, String?>();
      if (!(e is NestedQuestion || e is PolarQuestion))
        e.answer = new TextEditingController();
      temp[e] = null;

      return temp;
    }).toList();
    callback();
    //  _stream.sink.add(expanded);
  }

//  final _stream = StreamController<List<Map<Question, String>>>();
  List<Question> _questionStructure;
  late List<Map<Question, String?>> expanded;
  final callback;
  QuestionHandler(this._questionStructure, {this.callback}) {
    expanded = _questionStructure.map((e) {
      Map<Question, String?> temp = new Map<Question, String?>();
      if (!(e is NestedQuestion || e is PolarQuestion))
        e.answer = new TextEditingController();
      temp[e] = null;
      print(temp.keys);
      return temp;
    }).toList();

    // _stream.sink.add(expanded);
    callback();
  }
  //Stream<List<Map<Question, String>>> get stream => _stream.stream;

  ///This private method is used to used to set the answers or states of the question cards as
  ///and when the user taps on the choices.
  ///
  ///If there are instances of [NestedQuestion]
  ///its children will be expanded or unpacked based on the [answer].
  ///The parameter [questionState] contains the old state of the question.
  ///The [answer] parameter contains the new answer selected by the user.
  void _onEvent(Map<Question, String?> questionState, String? answer) {
    int location = 0;
    if ((location = expanded.indexOf(questionState)) != -1) {
      expanded[location][questionState.keys.toList()[0]] = answer;

      if (questionState.keys.toList()[0] is PolarQuestion)
        (questionState.keys.toList()[0] as PolarQuestion).hasError = false;

      if (questionState.keys.toList()[0] is NestedQuestion) {
        if (((questionState.keys.toList()[0] as NestedQuestion).children) !=
                null &&
            questionState[questionState.keys.toList()[0]] != null) {
          (questionState.keys.toList()[0] as NestedQuestion)
              .children!
              .forEach((key, value) {
            if (key != answer) {
              int count =
                  location + 1; //location value points after nested question
              value.forEach((element) {
                if (count < expanded.length &&
                        expanded[count].containsKey(element) ||
                    count < expanded.length &&
                        ( expanded[count]
                            .keys
                            .toList()[0]
                            .parent!=null && expanded[count]
                            .keys
                            .toList()[0]
                            .parent!
                            .containsKey(questionState.keys.toList()[0]))) {
                  expanded.removeAt(count);
                }
              });
            }
          });
          for (int i = location + 1; i < expanded.length; i++) {
            if (location + 1 < expanded.length &&
              (expanded[location + 1]
                  .keys
                  .toList()[0]
                  .parent!=null && expanded[location + 1]
                    .keys
                    .toList()[0]
                    .parent!
                    .containsKey(questionState.keys.toList()[0]))) {
              expanded.removeAt(location + 1);
            }
          }
          (questionState.keys.toList()[0] as NestedQuestion)
              .children!
              .forEach((key, value) {
            if (key == answer) {
              int count = location + 1;
              value.forEach((element) {
                Map<Question, String?> temp = new Map<Question, String?>();
                element.parent =
                    expanded[location].keys.toList()[0].parent == null
                        ? expanded[location]
                        : expanded[location].keys.toList()[0].parent;
                if (!(element is NestedQuestion || element is PolarQuestion))
                  element.answer = new TextEditingController();
                temp[element] = null;

                expanded.insert(count++, temp);
              });
            }
          });
        }
      }
    }
    callback();
    //_stream.sink.add(expanded);
  }

  ///This function is used to validate the question cards.
  ///
  /// Instances of [PolarQuestion] and [NestedQuestion] that have the [isMandatory]
  /// flag set will be checked if they are equal to null or not.
  /// Instances of [Question] having the validate property set to a function
  /// will execute that function.
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
        count++;
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
    print("count:$count");
    callback();
    if (count > 0)
      return false;
    else
      return true;
  }

  ///This function returns a list of widgets representing the question structure.
  ///
  /// This is the function that is meant to be called to see the results.
  List<Widget> getWidget(BuildContext context) {
    return expanded
        .map<Widget>((element) => this._getCard(context, element))
        .toList();
  }

  ///This function returns a widget corresponding to a particular question passed as the
  ///argument to it.
  ///
  /// The [data] parameter contains the state of a particular question.
  Widget _getCard(BuildContext context, Map<dynamic, dynamic> data) {
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
                                //check condition before applying star
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
                                            this._onEvent(
                                                data as Map<Question, String?>,
                                                string);
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
                                  ),
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

///A class that is used to represent the list of answers supplied to instances
///of [NestedQuestion] and/or [PolarQuestion]
///
/// It returns a Radio Button representing an answer that is passed as an argument to it.
class CustomRadioButton extends StatelessWidget {
  final answer;
  final data;
  final parent;

  CustomRadioButton({this.answer, this.data, this.parent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio(
          value: answer,
          groupValue: data[data.keys.toList()[0]],
          onChanged: (dynamic value) {
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
