import 'package:flutter_test/flutter_test.dart';

import 'package:conditional_questions/conditional_questions.dart';

void update() {
  print("updated.");
}

void main() {
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

  test('Class should load the question structure:', () {
    final questionManager = QuestionProvider(questions());
    Map<String, dynamic> temp = {};
    questions().forEach((e) {
      if (!(e is NestedQuestion || e is PolarQuestion))
        temp[e.toString()] = "";
      else
        temp[e.toString()] = null;
    });
    expect(questionManager.toMap(), temp);
  });

  test('setState should replace current state:', () {
    final questionManager = QuestionProvider(questions());
    Map<String, dynamic> temp = {
      "What is your name?": "mike",
      "Have you made any donations in the past?": "No",
      "In the last 3 months have you had a vaccination?": "No",
      "Have you ever taken medication for HIV?": "No",
      "The series will depend on your answer": "No",
      "Have you sustained any injuries?": "Yes",
      "Did it result in a disability?": "No"
    };
    questionManager.setState(temp);
    expect(questionManager.toMap(), temp);
  });

  test('ResetState should produce default state:', () {
    final questionManager = QuestionProvider(questions());
    Map<String, dynamic> temp = {
      "What is your name?": "mike",
      "Have you made any donations in the past?": "No",
      "In the last 3 months have you had a vaccination?": "No",
      "Have you ever taken medication for HIV?": "No",
      "The series will depend on your answer": "No",
      "Have you sustained any injuries?": "Yes",
      "Did it result in a disability?": "No"
    };
    questionManager.setState(temp);
    expect(questionManager.toMap(), temp);
    questionManager.resetState();
    expect(questionManager.toMap(), {
      "What is your name?": "",
      "Have you made any donations in the past?": null,
      "In the last 3 months have you had a vaccination?": null,
      "Have you ever taken medication for HIV?": null,
      "The series will depend on your answer": null
    });
  });

  test('validation test:', () {
    final questionManager = QuestionProvider(questions());
    Map<String, dynamic> temp = {
      "What is your name?": "mike",
      "Have you made any donations in the past?": "No",
      "In the last 3 months have you had a vaccination?": "No",
      "Have you ever taken medication for HIV?": "No",
      "The series will depend on your answer": "No",
      "Have you sustained any injuries?": "Yes",
      "Did it result in a disability?": "No"
    };
    questionManager.setState(temp);
    expect(questionManager.toMap(), temp);
    expect(questionManager.validate(), true);
    questionManager.resetState();
    expect(questionManager.validate(), false);
  });
}
