import 'package:conditional_questions/conditional_questions.dart';

///A class that represents a standard question and an answer
/// that is not restricted to a set of options.
///
/// It accepts the parameters [question], which is of type [String],
/// [parent] which is of type Map<Question,String> that is used to denote
/// the state of its parent Question, if any.
/// The [validate] parameter accepts a function to perform validation on the
/// answer provided to the question.
class Question {
  Question({required String this.question, this.parent, this.validate});

  final String? question;
  late TextEditingController answer;
  Map<Question, String?>? parent;
  //bool isMandatory;
  final validate;
  bool hasError = false;
  String? errorMessage;

  @override
  String toString() {
    return question!;
  }
}

///A class that represents a Closed-Ended question.
///
/// It accepts the parameters [question], which is of type [String],
/// [parent] which is of type Map<Question,String> that is used to denote
/// the state of its parent Question, if any.
/// The [answer] parameter specifies the list of options to choose from and the not the actual answer
/// selected by the user.
/// The [isMandatory] parameter is used to specify if the question cannot be left
/// unanswered.
///
class PolarQuestion extends Question {
  PolarQuestion(
      {required String this.question,
      List<String> this.answers = const ["Yes", "No"],
      this.parent,
      this.isMandatory = false,
      this.isCheckBox = false})
      : super(
          question: question,
          parent: parent,
        );
  final List<String>? answers;
  final String? question;
  Map<Question, String?>? parent;
  final isMandatory;
  final isCheckBox;
  bool hasError = false;
}

///A class that represents a Closed-Ended question which
///mainly implements conditional questions.
///
/// It accepts the parameters [question], which is of type [String],
/// [parent] which is of type Map<Question,String> that is used to denote
/// the state of its parent Question, if any.
/// The [answer] parameter specifies the list of options to choose from and the not the actual answer
/// selected by the user.
/// The [isMandatory] parameter is used to specify if the question cannot be left
/// unanswered.
///What makes this class different from its parent class [PolarQuestion]
///is that an instance of the [NestedQuestion] class has a [children] property which houses a list of
///questions that follow, based on the choice made.
///The [children] property can also contain instances of [NestedQuestion].
class NestedQuestion extends PolarQuestion {
  NestedQuestion(
      {required question,
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
  String? question;
  List<String>? answers;
  Map<String, List<Question>>? children;

  Map<Question, String?>? parent;
  bool? isMandatory;
  bool hasError = false;
}

///A model that neatly hold a question and its corresponding answer.
///can be used by other widgets to display the question and answer.
class FormElement {
  FormElement({this.question, this.answer});
  final question;
  final answer;
}
