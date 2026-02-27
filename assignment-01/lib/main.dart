import 'package:flutter/material.dart';
import 'buttons.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ); // MaterialApp
  }
}

//userInput AND answer change moat every calculation so to update these in the UI, we need a stateful widget
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var userInput = '';
  var answer = '';

  // Array of button
  final List<String> buttons = [
    'C',
    '+/-',
    '%',
    'DEL',
    '7',
    '8',
    '9',
    '/',
    '4',
    '5',
    '6',
    'x',
    '1',
    '2',
    '3',
    '-',
    '0',
    '.',
    '=',
    '+',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: new Text("Calculator")), //AppBar
      backgroundColor: Colors.white38,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    alignment: Alignment.centerRight,
                    child: Text(
                      answer, //  (small, previous expression)
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    alignment: Alignment.centerRight,
                    child: Text(
                      userInput, //(large, current calculation)
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              child: GridView.builder(
                itemCount: buttons.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemBuilder: (BuildContext context, int index) {
                  // Clear Button
                  if (index == 0) {
                    return MyButton(
                      buttontapped: () {
                        setState(() {
                          userInput = '';
                          answer = '0';
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.blue[50],
                      textColor: Colors.black,
                    );
                  }
                  // +/- button
                  else if (index == 1) {
                    return MyButton(
                      buttontapped: () {
                        setState(() {
                          if (userInput.isNotEmpty) {
                            if (userInput.startsWith('-')) {
                              userInput = userInput.substring(
                                1,
                              ); //removes minus
                            } else {
                              userInput =
                                  '-$userInput'; //Use interpolation to compose strings and values
                            }
                          }
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.blue[50],
                      textColor: Colors.black,
                    );
                  }
                  // % Button
                  else if (index == 2) {
                    return MyButton(
                      buttontapped: () {
                        setState(() {
                          userInput += buttons[index];
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.blue[50],
                      textColor: Colors.black,
                    );
                  }
                  // Delete Button
                  else if (index == 3) {
                    return MyButton(
                      buttontapped: () {
                        setState(() {
                          if (userInput.isNotEmpty) {
                            //is not Empty guard
                            userInput = userInput.substring(
                              0,
                              userInput.length - 1,
                            );
                          }
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.blue[50],
                      textColor: Colors.black,
                    );
                  }
                  // Equal_to Button
                  else if (index == 18) {
                    return MyButton(
                      buttontapped: () {
                        setState(() {
                          equalPressed();
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.orange[700],
                      textColor: Colors.white,
                    );
                  }
                  //  other buttons
                  else {
                    return MyButton(
                      buttontapped: () {
                        setState(() {
                          // if screen shows an error, clear it before adding new input
                          if (userInput == 'Error' || userInput == 'Cannot divide by 0') { //if screen shows an error{
                            userInput = ''; 
                            answer = '';
                            //clear
                          }
                          userInput += buttons[index];
                        });
                      },
                      buttonText: buttons[index],
                      color: isOperator(buttons[index])
                          ? Colors.blueAccent
                          : Colors.white,
                      textColor: isOperator(buttons[index])
                          ? Colors.white
                          : Colors.black,
                    );
                  }
                },
              ), // GridView.builder
            ),
          ),
        ],
      ),
    );
  }

  bool isOperator(String x) {
    if (x == '/' || x == 'x' || x == '-' || x == '+' || x == '=') {
      return true;
    }
    return false;
  }

  // function to calculate the input operation
  void equalPressed() {
    try {
      String finaluserinput = userInput.replaceAll('x', '*');

      GrammarParser p = GrammarParser();
      Expression exp = p.parse(finaluserinput);
      RealEvaluator evaluator = RealEvaluator();
      num eval = evaluator.evaluate(exp);
      answer = userInput;
      userInput = eval % 1 == 0 ? eval.toInt().toString() : eval.toString();

      //DIVISION by zero error handler
      if (eval.isInfinite || eval.isNaN) {
        answer = userInput;
        userInput = 'Cannot divide by 0';
      } else {}
    } catch (e) {
      answer = userInput;
      userInput = 'Error';
    }
  }
}
