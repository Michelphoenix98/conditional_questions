import 'package:conditional_questions/conditional_questions.dart';

///A class that is used to represent the list of answers supplied to instances
///of [NestedQuestion] and/or [PolarQuestion]
///
/// It returns a Radio Button representing an answer that is passed as an argument to it.
class CustomRadioButton extends StatelessWidget {
  ///The [answer] variable is of type String which will be displayed along side the radio button
  final answer;

  ///The [data] parameter contains the state of a particular question.
  final data;

  CustomRadioButton({this.answer, this.data});

  @override
  Widget build(BuildContext context) {
    var questionProvider = Provider.of<QuestionProvider>(context);
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
            questionProvider.onEvent(data, value);
          },
        ),
        Text(answer),
      ],
    );
  }
}
