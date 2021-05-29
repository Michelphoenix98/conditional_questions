import 'package:conditional_questions/conditional_questions.dart';

///A provider that manages the state of the questions.
///
/// accepts a parameter of type List<Question>, which is a list of [Question] objects
/// that specifies the structure of the questionnaire.
class QuestionProvider extends ChangeNotifier {
  List<Question> _questionStructure;
  late List<Map<Question, String?>> _expanded;

  List<Map<Question, String?>> get expanded => _expanded;
  late final value;
  late final leading;
  late final trailing;

  ///This method returns a Map<String,String> object of the
  ///current state of the question cards.
  ///This format is useful for writing to a database eg Firestore.
  Map<String, dynamic> toMap() {
    Map<String, dynamic> temp = new Map<String, dynamic>();
    _expanded.forEach((element) {
      String? answer = (!(element.keys.toList()[0] is NestedQuestion ||
              element.keys.toList()[0] is PolarQuestion))
          ? element.keys.toList()[0].answer.text
          : element[element.keys.toList()[0]];
      temp[element.keys.toList()[0].toString()] = answer;
    });
    return temp;
  }

  ///This function returns an ordered list of questions and their respective answers,
  ///the data can be used by other widgets.
  List<FormElement> getElementList() {
    List<FormElement> temp = [];
    _expanded.forEach((element) {
      String? answer = (!(element.keys.toList()[0] is NestedQuestion ||
              element.keys.toList()[0] is PolarQuestion))
          ? element.keys.toList()[0].answer.text
          : element[element.keys.toList()[0]];
      temp.add(FormElement(
          question: element.keys.toList()[0].toString(), answer: answer));
    });
    return temp;
  }

  void notifyChanges() {
    notifyListeners();
  }

  ///This method is used to set the state of the cards containing the questions and answers.
  ///
  /// It accepts a parameter [doc] of type Map<String,String> which essentially contains
  /// an unordered list of question:answer key:value pairs typically fetched from a database.
  /// This method sets the state and arranges the questions according to the order
  /// specified by the [_questionStructure] variable.
  void setState(Map<String, dynamic> doc) {
    this.resetState();
    for (int i = 0; i < _expanded.length; i++) {
      doc.keys.forEach((field) {
        if (_expanded[i].keys.toList()[0].toString() == field) {
          if (!(_expanded[i].keys.toList()[0] is NestedQuestion ||
              _expanded[i].keys.toList()[0] is PolarQuestion))
            _expanded[i].keys.toList()[0].answer.text = doc[field];

          this.onEvent(_expanded[i], doc[field]);
        }
      });
    }
  }

  ///The resetState() method is, as its name implies,
  ///used to revert the states of all the cards back to its
  ///default state(null).
  void resetState() {
    _expanded.clear();
    _expanded = _questionStructure.map((e) {
      Map<Question, String?> temp = new Map<Question, String?>();
      if (!(e is NestedQuestion || e is PolarQuestion))
        e.answer = new TextEditingController();
      temp[e] = null;

      return temp;
    }).toList();
    notifyListeners();
  }

  QuestionProvider(this._questionStructure,
      {this.leading, this.trailing, this.value}) {
    _expanded = _questionStructure.map((e) {
      Map<Question, String?> temp = new Map<Question, String?>();
      if (!(e is NestedQuestion || e is PolarQuestion))
        e.answer = new TextEditingController();
      temp[e] = null;
      print(temp.keys);
      return temp;
    }).toList();
    if (value != null)
      setState(value);
    else
      notifyListeners();
  }

  ///This method is used to used to set the answers or states of the question cards as
  ///and when the user taps on the choices.
  ///
  ///If there are instances of [NestedQuestion]
  ///its children will be expanded or unpacked based on the [answer].
  ///The parameter [questionState] contains the old state of the question.
  ///The [answer] parameter contains the new answer selected by the user.
  void onEvent(Map<Question, String?> questionState, String? answer) {
    int location = 0;
    if ((location = _expanded.indexOf(questionState)) != -1) {
      _expanded[location][questionState.keys.toList()[0]] = answer;

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
                if (count < _expanded.length &&
                        _expanded[count].containsKey(element) ||
                    count < _expanded.length &&
                        _expanded[count].keys.toList()[0].parent != null &&
                        _expanded[count]
                            .keys
                            .toList()[0]
                            .parent!
                            .containsKey(questionState.keys.toList()[0])) {
                  _expanded.removeAt(count);
                }
              });
            }
          });
          for (int i = location + 1; i < _expanded.length; i++) {
            if (location + 1 < _expanded.length &&
                _expanded[location + 1].keys.toList()[0].parent != null &&
                _expanded[location + 1]
                    .keys
                    .toList()[0]
                    .parent!
                    .containsKey(questionState.keys.toList()[0])) {
              _expanded.removeAt(location + 1);
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
                    _expanded[location].keys.toList()[0].parent == null
                        ? _expanded[location]
                        : _expanded[location].keys.toList()[0].parent;
                if (!(element is NestedQuestion || element is PolarQuestion))
                  element.answer = new TextEditingController();
                temp[element] = null;

                _expanded.insert(count++, temp);
              });
            }
          });
        }
      }
    }

    notifyListeners();
  }

  ///This function is used to validate the question cards.
  ///
  /// Instances of [PolarQuestion] and [NestedQuestion] that have the [isMandatory]
  /// flag set will be checked if they are equal to null or not.
  /// Instances of [Question] having the validate property set to a function
  /// will execute that function.
  bool validate() {
    int count = 0;

    _expanded.forEach((element) {
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

    notifyListeners();
    if (count > 0)
      return false;
    else
      return true;
  }
}
