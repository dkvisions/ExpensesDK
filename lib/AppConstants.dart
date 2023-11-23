// ignore: file_names

import 'package:expensemanager/ExpenseModel.dart';
import 'package:flutter/material.dart';

enum DialogforEnum { login, dashboard }

class AppConstants {
  static final AppConstants constantsInstance = AppConstants._internal();

  static String loginDataLocal = "loginDataFromLocal";
  static String currentUser = "CurrentUser";

  factory AppConstants() {
    return constantsInstance;
  }

  void _init() async {}

  AppConstants._internal() {
    // initialization logic
    _init();
  }

  showAlertDialogWithButton(BuildContext context, String title,
      String alertMessage, DialogforEnum dialogforType,
      {LoginCredentialsModel? detail, (String, String)? userSignUpDetails}) {
    // set up the buttons

    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    String actionName = "Ok";
    switch (dialogforType) {
      case DialogforEnum.login:
        actionName = "Create";

      default:
        break;
    }

    Widget continueButton = TextButton(
      child: Text(actionName),
      onPressed: () {
        switch (dialogforType) {
          case DialogforEnum.login:
            print("User wants to create new Account");

            print("From Second $detail detail $detail");
            if (detail == null) {
              LoginCredentialsModel allDetails = LoginCredentialsModel(
                  loginDetails: [
                    LoginDetails(
                        userID: userSignUpDetails!.$1,
                        password: userSignUpDetails.$2)
                  ]);

              SharedPreferencesSaveRetrieve.saveUserCredentialsToLocalStorage(
                  allDetails);

              print("First Account");
            } else {
              print("From Second $detail detail $detail");

              detail.loginDetails.add(LoginDetails(
                  userID: userSignUpDetails!.$1,
                  password: userSignUpDetails.$2));

              SharedPreferencesSaveRetrieve.saveUserCredentialsToLocalStorage(
                  detail);

              print("more than 1 Account");
            }
            Navigator.pop(context);
            showDialogWithDuration(context, "New Account Created");

            break;

          case DialogforEnum.dashboard:
            Navigator.pop(context);
            Navigator.pop(context);
            break;
          default:
            Navigator.pop(context);
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      content: Text(alertMessage, textAlign: TextAlign.center),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //Show Dialog Alert
  Future<dynamic> showDialogWithDuration(BuildContext context, String message) {
    return showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pop(true);
            // navigate to next Screen
          });
          return AlertDialog(
            title: Text(
              message,
              textAlign: TextAlign.center,
            ),
            alignment: Alignment.bottomCenter,
            titleTextStyle:
                const TextStyle(fontSize: 14, color: Colors.blueGrey),
          );
        });
  }
}
