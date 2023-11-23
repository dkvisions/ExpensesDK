// ignore: file_names

//Login Model-----------------------------------------------------------

import 'dart:convert';
import 'package:expensemanager/AppConstants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginCredentialsModel {
  List<LoginDetails> loginDetails;

  LoginCredentialsModel({
    required this.loginDetails,
  });

  factory LoginCredentialsModel.fromRawJson(String str) =>
      LoginCredentialsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginCredentialsModel.fromJson(Map<String, dynamic> json) =>
      LoginCredentialsModel(
        loginDetails: List<LoginDetails>.from(
            json["loginDetails"].map((x) => LoginDetails.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "loginDetails": List<dynamic>.from(loginDetails.map((x) => x.toJson())),
      };
}

class LoginDetails {
  String userID;
  String password;

  LoginDetails({
    required this.userID,
    required this.password,
  });

  factory LoginDetails.fromRawJson(String str) =>
      LoginDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginDetails.fromJson(Map<String, dynamic> json) => LoginDetails(
        userID: json["userID"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "userID": userID,
        "password": password,
      };
}

//Expense Model-----------------------------------------------------------
class ExpenseModel {
  List<ExpenseModelElement> expenseModel;

  ExpenseModel({
    required this.expenseModel,
  });

  factory ExpenseModel.fromRawJson(String str) =>
      ExpenseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        expenseModel: List<ExpenseModelElement>.from(
            json["ExpenseModel"].map((x) => ExpenseModelElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ExpenseModel": List<dynamic>.from(expenseModel.map((x) => x.toJson())),
      };
}

class ExpenseModelElement {
  String id;
  String date;
  String expenseName;
  double amount;
  String expenseType;
  String paymentMode;

  ExpenseModelElement({
    required this.id,
    required this.date,
    required this.expenseName,
    required this.amount,
    required this.expenseType,
    required this.paymentMode,
  });

  factory ExpenseModelElement.fromRawJson(String str) =>
      ExpenseModelElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ExpenseModelElement.fromJson(Map<String, dynamic> json) =>
      ExpenseModelElement(
        id: json["id"],
        date: json["date"],
        expenseName: json["expenseName"],
        amount: json["amount"].toDouble(),
        expenseType: json["expenseType"],
        paymentMode: json["paymentMode"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "expenseName": expenseName,
        "amount": amount,
        "expenseType": expenseType,
        "paymentMode": paymentMode,
      };
}

//Save To local storage

class SharedPreferencesSaveRetrieve {
  //------------------------------------------------------------
  static Future<void> saveUserCredentialsToLocalStorage(
      LoginCredentialsModel data) async {
    var prefs = await SharedPreferences.getInstance();

    String dataInJson = jsonEncode(data.toJson());
    //Save in local Storage
    prefs.setString(AppConstants.loginDataLocal, dataInJson);
  }

  static Future<LoginCredentialsModel>
      retrieveUserCredentialsFromLocalStorage() async {
    var prefs = await SharedPreferences.getInstance();

    String dataFromLocal = prefs.getString(AppConstants.loginDataLocal) ?? '';

    if (dataFromLocal == '') {
      return LoginCredentialsModel(
          loginDetails: [LoginDetails(userID: "", password: "")]);
    } else {
      var modelData = LoginCredentialsModel.fromJson(jsonDecode(dataFromLocal));

      return modelData;
    }
  }

//-------------------------------------------------------------------
  static Future<void> saveUsersDataToLocalStorage(
      ExpenseModel data, String userID) async {
    var prefs = await SharedPreferences.getInstance();

    String dataInJson = jsonEncode(data.toJson());
    //Save in local Storage
    prefs.setString(userID, dataInJson);
  }

  static Future<ExpenseModel> retrievesUsersDataFromLocalStorage(
      String userID) async {
    var prefs = await SharedPreferences.getInstance();

    //Retrieve from local Storage
    String dataFromLocal = prefs.getString(userID) ?? '';

    if (dataFromLocal == '') {
      return ExpenseModel(expenseModel: []);
    } else {
      var modelData = ExpenseModel.fromJson(jsonDecode(dataFromLocal));
      return modelData;
    }
  }
//-------------------------------------------------------------------
}
