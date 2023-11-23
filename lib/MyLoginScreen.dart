import "dart:convert";

import "package:expensemanager/AppConstants.dart";
import "package:expensemanager/ExpenseModel.dart";
import "package:expensemanager/ScreensContainer.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class MyLoginScreen extends StatefulWidget {
  const MyLoginScreen({super.key});

  @override
  State<MyLoginScreen> createState() => _MyLoginScreenState();
}

class _MyLoginScreenState extends State<MyLoginScreen> {
  TextEditingController userIDController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var isLoading = false;

  LoginCredentialsModel allDetails = LoginCredentialsModel(loginDetails: []);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUserDetailsFromSharedPreference().then((value) {
      userIDController.text = value["userID"] ?? "";
      passwordController.text = value["password"] ?? "";
    });
  }

  saveUserDeatailsToSharedPref(String userID, String password) async {
    var prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> user = {'userID': userID, 'password': password};
    prefs.setString(AppConstants.currentUser, jsonEncode(user));
  }

  Future<Map<String, dynamic>> getUserDetailsFromSharedPreference() async {
    var prefs = await SharedPreferences.getInstance();
    String userPref = prefs.getString(AppConstants.currentUser) ?? "";

    if (userPref == "") {
      return {'userID': "", 'password': ""};
    }
    Map<String, dynamic> userMap = jsonDecode(userPref) as Map<String, dynamic>;
    return userMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              print("Clicked---");
              (bool, LoginDetails?, LoginCredentialsModel?) isExists =
                  await checkIsUserExist();

              if (isExists.$3 != null) {
                print("notNull");
                // ignore: use_build_context_synchronously
                allDetails = isExists.$3!;
                // ignore: use_build_context_synchronously
                showDialogForALlUser(context);
              } else {
                // ignore: use_build_context_synchronously
                showDialogWithDuration(
                    context, "There is no user in the database", false);
              }
            },
            child: const Text(
              'All Users',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text(
                        "Login to your account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    Container(
                      height: 280,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          // color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(
                                5.0,
                                3.0,
                              ),
                              blurRadius: 5.0,
                              spreadRadius: 1.0,
                            ), //BoxShadow
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.5,
                            ),
                          ]),
                      child: FieldsColumn(context),
                    ),
                    const Spacer(),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(8, 8, 8, 15),
                          child: Text(
                            "Powered by it's Dk",
                            style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 8,
                                fontStyle: FontStyle.italic),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Column FieldsColumn(BuildContext context,
      {bool isUpdate = false, LoginDetails? loginDetail}) {
    TextEditingController uID = TextEditingController();
    TextEditingController pwd = TextEditingController();

    uID.text = loginDetail?.userID ?? "";
    pwd.text = loginDetail?.password ?? "";
    return Column(
      mainAxisSize: MainAxisSize.min,
      verticalDirection: VerticalDirection.down,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "User ID",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: isUpdate ? uID : userIDController,
                textAlign: TextAlign.start,
                decoration: const InputDecoration(
                    hintText: "Enter your user ID / Email",
                    icon: ImageIcon(
                      AssetImage("assets/images/UserID.png"),
                    ),
                    iconColor: Colors.blue),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Password",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: isUpdate ? pwd : passwordController,
                textAlign: TextAlign.start,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                    hintText: "Enter your password",
                    icon: ImageIcon(
                      AssetImage("assets/images/Password.png"),
                    ),
                    iconColor: Colors.blue),
              ),
              !isUpdate
                  ? Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (userIDController.text == "") {
                            showDialogWithDuration(context,
                                "Please enter you userID/Email", false);
                            return;
                          }
                          (
                            bool,
                            LoginDetails?,
                            LoginCredentialsModel?
                          ) isExists = await checkIsUserExist();

                          if (isExists.$1) {
                            // ignore: use_build_context_synchronously
                            showDialogWithDuration(
                                context,
                                "Your password againsts (${userIDController.text}) is : ${isExists.$2!.password}",
                                false);
                          } else {
                            // ignore: use_build_context_synchronously
                            showDialogWithDuration(
                                context,
                                "User does not Exists \n\n You can create a new account by clicking on Submit Button",
                                false);
                          }
                        },
                        child: const Center(
                          child: Text(
                            "Forgot Password? Click Here",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isUpdate
                  ? GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Color(0xFF1BC0C5),
                        ),
                        alignment: Alignment.center,
                        height: 40,
                        width: isUpdate ? 120 : 250,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Dismiss",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              isUpdate ? const Spacer() : const SizedBox(),
              GestureDetector(
                onTap: () async {
                  if (isUpdate) {
                    if (uID.text != "" && pwd.text != "") {
                      if (loginDetail != null) {
                        deleteUserFromDB(loginDetail.userID,
                            updatedUserID: uID.text,
                            password: pwd.text,
                            isUpdate: true);
                        Navigator.pop(context);
//Needs to do something
                        Navigator.pop(context);
                      }
                    } else {
                      showDialogWithDuration(
                          context, "Please enter UserID/Password", false);
                    }

                    print(loginDetail?.password);
                    return;
                  }

                  if (userIDController.text != "" &&
                      passwordController.text != "") {
                    (bool, LoginDetails?, LoginCredentialsModel?) isExists =
                        await checkIsUserExist();

                    print(isExists);
                    //-------------------------------
                    if (isExists.$1) {
                      if (passwordController.text == isExists.$2!.password) {
                        // ignore: use_build_context_synchronously
                        showDialogWithDuration(context, "Login  success", true,
                            userID: isExists.$2!.userID);
                        await saveUserDeatailsToSharedPref(
                            userIDController.text, passwordController.text);
                      } else {
                        // ignore: use_build_context_synchronously
                        showDialogWithDuration(
                            context, "Password is incorrect", false);
                      }
                    } else {
                      var userID = userIDController.text;
                      var password = passwordController.text;

                      // ignore: use_build_context_synchronously
                      AppConstants.constantsInstance.showAlertDialogWithButton(
                          context,
                          "User Not Exists",
                          "Do you want to create new account with UserID: $userID and Password: $password ?",
                          DialogforEnum.login,
                          detail: isExists.$3,
                          userSignUpDetails: (
                            userIDController.text,
                            passwordController.text
                          ));
                    }

                    //-------------------------------
                  } else {
                    showDialogWithDuration(
                        context, "Please enter UserID/Password", false);
                  }
                },
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    color: Colors.blue,
                  ),
                  alignment: Alignment.center,
                  height: 40,
                  width: isUpdate ? 120 : 250,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      isUpdate ? "Update" : "Submit",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //Check is User Exists

  Future<(bool, LoginDetails?, LoginCredentialsModel? allCredentials)>
      checkIsUserExist() async {
    var details = await SharedPreferencesSaveRetrieve
        .retrieveUserCredentialsFromLocalStorage();

    bool isPresent = false;
    bool isDataPresent = false;

    LoginDetails detail = LoginDetails(userID: "", password: "");

    for (var element in details.loginDetails) {
      if (element.userID == userIDController.text) {
        isPresent = true;
        detail = element;
      }
      isDataPresent = true;
      if (element.userID == "") {
        isDataPresent = false;
      }
    }

    if (isPresent) {
      return (true, detail, details);
    } else if (isDataPresent) {
      return (false, null, details);
    } else {
      return (false, null, null);
    }
  }

  //Show Dialog Alert

  Future<dynamic> showDialogWithDuration(
      BuildContext context, String message, bool isSuccess,
      {String userID = ''}) {
    setState(() {
      isLoading = true;
    });

    return showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(milliseconds: 600), () {
            Navigator.of(context).pop(true);
            setState(() {
              isLoading = false;
            });
            // navigate to next Screen

            if (isSuccess) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ScreensContainer(userID)),
              );
            }
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

  //Custom Dialog
  StateSetter? setStateDialog;

  showDialogForALlUser(BuildContext context,
      {bool isUpdate = false, int? index}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              //shape: RoundedRectangleBorder(
              //borderRadius: BorderRadius.circular(20.0)), //this right here

              child:
                  StatefulBuilder(// You need this, notice the parameters below:
                      builder: (BuildContext context, StateSetter setState) {
            setStateDialog = setState;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue.shade50,
              ),

              height: isUpdate ? 300 : 420,
              // width: 300,
              child: isUpdate
                  ? SizedBox(
                      child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FieldsColumn(context,
                          isUpdate: true,
                          loginDetail: index != null
                              ? allDetails.loginDetails[index]
                              : null),
                    ))
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 335,
                            child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: allDetails.loginDetails.length,
                                itemBuilder: (BuildContext context, int index) {
                                  print(
                                      "nyam : ${allDetails.loginDetails[index].userID}");
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                          color: Colors.indigo.shade50,
                                          border: Border.all(
                                              width: 0.5,
                                              color: Colors.blueGrey),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              'User ID ${index + 1}: \n${allDetails.loginDetails[index].userID}',
                                              maxLines: 2,
                                            ),
                                            const Spacer(),
                                            SizedBox(
                                              width: 15,
                                              height: 15,
                                              // color: Colors.brown[100],
                                              child: GestureDetector(
                                                onTap: () {
                                                  print("Update... Tapped");

                                                  showDialogForALlUser(context,
                                                      isUpdate: true,
                                                      index: index);
                                                },
                                                child: const ImageIcon(
                                                  AssetImage(
                                                      "assets/images/UpdateImage.png"),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 0, 0, 0),
                                              child: SizedBox(
                                                width: 15,
                                                height: 15,
                                                // color: Colors.brown[100],
                                                child: GestureDetector(
                                                  onTap: () {
                                                    print("Delete Tapped");

                                                    showAlertDialogOkButotn(
                                                        context,
                                                        "Delete User ID permanently",
                                                        "Deleting the User-ID will delete All your Data, relate's to it.\nDo you really want to delete this ID?",
                                                        isDelete: true,
                                                        userID: allDetails
                                                            .loginDetails[index]
                                                            .userID);
                                                  },
                                                  child: const ImageIcon(
                                                    AssetImage(
                                                        "assets/images/DeleteImage.png"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 200.0,
                            height: 40,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color(0xFF1BC0C5)),
                                child: const Center(
                                  child: Text(
                                    "Dismiss",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
            );
          }));
        });
  }

  void showAlertDialogOkButotn(
      BuildContext context, String title, String message,
      {String userID = "", bool isDelete = false}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title, textAlign: TextAlign.center),
              content: Text(message),
              actions: <Widget>[
                isDelete
                    ? Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text('Delete'),
                          onPressed: () {
                            Navigator.pop(context);

                            deleteUserFromDB(userID);
                            // ExpenseModelElement? elemetFound;
                            // for (var element in expenses.expenseModel) {
                            //   if (dateId == element.date) {
                            //     elemetFound = element;
                            //   }
                            // }
                            // if (elemetFound != null) {
                            //   setState(() {
                            //     expenses.expenseModel.remove(elemetFound);
                            //     filterredExpenses.expenseModel
                            //         .remove(elemetFound);
                            //   });
                            //   SharedPreferencesSaveRetrieve
                            //       .saveUsersDataToLocalStorage(
                            //           expenses, widget.userID);
                            // }

                            //Delete Data
                          },
                        ),
                      )
                    : const Text(""),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Dismiss'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ));
  }

  @pragma(' Delete Methode')
  deleteUserFromDB(String userID,
      {bool isUpdate = false,
      String updatedUserID = "",
      String password = ""}) async {
    LoginDetails? toDeleteData;
    var pref = await SharedPreferences.getInstance();

    int? indexNumber;

    if (isUpdate) {
//Update Data

      toDeleteData = LoginDetails(userID: updatedUserID, password: password);

      for (int i = 0; i < allDetails.loginDetails.length; i++) {
        if (allDetails.loginDetails[i].userID == userID) {
          indexNumber = i;

          break;
        }
      }

      if ((setStateDialog != null) && (indexNumber != null)) {
        setStateDialog!(() {
          print("object1New");
          allDetails.loginDetails[indexNumber!] =
              LoginDetails(userID: updatedUserID, password: password);
        });
      }

      var userData = await SharedPreferencesSaveRetrieve
          .retrievesUsersDataFromLocalStorage(userID);

      SharedPreferencesSaveRetrieve.saveUsersDataToLocalStorage(
          userData, updatedUserID);
    } else {
      //Delete Data
      for (var element in allDetails.loginDetails) {
        if (element.userID == userID) {
          toDeleteData = element;
        }
      }

      if (toDeleteData != null) {
        print("object");

        if (setStateDialog != null) {
          setStateDialog!(() {
            allDetails.loginDetails.remove(toDeleteData);
          });
        }
      }
    }
    pref.remove(userID);
    print("object13");
    SharedPreferencesSaveRetrieve.saveUserCredentialsToLocalStorage(allDetails);
  }
}
