import 'package:conditional_questions/conditional_questions.dart';

///[ConditionalQuestions] a widget that accepts a structured list of questions and renders them.
///returns a ListView.
class ConditionalQuestions extends StatelessWidget {
  ///[children] is a parameter of type List<Question>, which is a list of [Question] objects
  /// that specifies the structure of the questionnaire.
  final children;

  ///[trailing] is a parameter of type List<Widget>, these widgets are rendered after the questionnaire form.
  late final trailing;

  ///[leading] is a parameter of type List<Widget>, these widgets are rendered before the questionnaire form.
  late final leading;

  ///[value] is a parameter of type Map<dynamic,dynamic>, this used to initialize the state of this widget.
  late final value;

  ///[subKey] is used to manipulate this widget and access other functions.
  late final subKey;
  @override
  ConditionalQuestions(
      {Key? key,
      required this.children,
      this.leading,
      this.trailing,
      this.value}) {
    this.subKey = key;
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: QuestionProvider(this.children,
              trailing: this.trailing,
              leading: this.leading,
              value: this.value),
        ),
      ],
      child: QuestionForm(key: subKey),
    );
  }
}

///This widget is responsible for the actual rendering of the Questionnaire form as a whole.
class QuestionForm extends StatefulWidget {
  QuestionForm({Key? key}) : super(key: key);
  @override
  QuestionFormState createState() => QuestionFormState();
}

class QuestionFormState extends State<QuestionForm> {
  @override
  Widget build(BuildContext context) {
    var questionProvider = Provider.of<QuestionProvider>(context);
    return ListView(
      shrinkWrap: true,
      children: [
        if (questionProvider.leading != null)
          ...(questionProvider.leading.map<Widget>((element) {
            return Center(
              child: element,
            );
          }).toList()),
        ...questionProvider.expanded
            .map<Widget>((element) => this._getCard(element))
            .toList(),
        if (questionProvider.trailing != null)
          ...(questionProvider.trailing.map<Widget>((element) {
            return Center(
              child: element,
            );
          }).toList()),
      ],
    );
  }

  ///This method returns a Map<String,String> object of the
  ///current state of the question cards.
  ///This format is useful for writing to a database eg Firestore.
  Map<String, dynamic> toMap() {
    var questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);
    return questionProvider.toMap();
  }

  ///This function returns an ordered list of questions and their respective answers,
  ///the data can be used by other widgets.
  List<FormElement> getElementList() {
    var questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);
    return questionProvider.getElementList();
  }

  ///This method is used to set the state of the cards containing the questions and answers.
  ///
  /// It accepts a parameter [doc] of type Map<String,String> which essentially contains
  /// an unordered list of question:answer key:value pairs typically fetched from a database.
  /// This method sets the state and arranges the questions according to the order
  /// specified by the [_questionStructure] variable.
  void convertState(Map<String, dynamic> doc) {
    var questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);
    questionProvider.setState(doc);
  }

  ///The resetState() method is, as its name implies,
  ///used to revert the states of all the cards back to its
  ///default state(null).
  void resetState() {
    var questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);
    questionProvider.resetState();
  }

  ///This function is used to validate the question cards.
  ///
  /// Instances of [PolarQuestion] and [NestedQuestion] that have the [isMandatory]
  /// flag set will be checked if they are equal to null or not.
  /// Instances of [Question] having the validate property set to a function
  /// will execute that function.
  bool validate() {
    var questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);
    return questionProvider.validate();
  }

  ///This function returns a widget corresponding to a particular question passed as the
  ///argument to it.
  ///
  /// The [data] parameter contains the state of a particular question.
  Widget _getCard(Map<dynamic, dynamic> data) {
    var questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);
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
                                            questionProvider.onEvent(
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
