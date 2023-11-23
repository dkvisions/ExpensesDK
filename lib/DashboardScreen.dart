import 'dart:io';

import 'package:expensemanager/AppConstants.dart';
import 'package:expensemanager/ExpenseModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final String userID;

  const DashboardScreen(this.userID, {super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ExpenseModel expenses = ExpenseModel(expenseModel: []);

  ExpenseModel filterredExpenses = ExpenseModel(expenseModel: []);

  TextEditingController expenseNameTextField = TextEditingController();
  TextEditingController expenseAmountTextField = TextEditingController();
  String dateFormattedString = 'dd-MM-yyyy hh:mm:ss';
  List<String> paymentMode = ["Cash", "Credit", "Debit", "UPI"];
  List<String> expenseType = [
    "Personal",
    "Credit Card",
    "Travel",
    "Vacation",
    "Food",
    "Entertainment",
    "Health Care"
  ];

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  int selectedMonth = 1;

  String dropDownExpenseType = "Personal";
  String dropDonwPaymentMode = "Cash";

  /*

  date
  String expenseName;
  double amount;
  String expenseType;
  String paymentMode;
  */

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      selectedMonth = getMonthName();
    });
    getExpenses();
  }

  getExpenses() {
    SharedPreferencesSaveRetrieve.retrievesUsersDataFromLocalStorage(
            widget.userID)
        .then((value) {
      setState(() {
        expenses = value;

        filterExpenseListByMonth();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AppConstants.constantsInstance.showAlertDialogWithButton(context,
            "Logout", "Do you want to logout?", DialogforEnum.dashboard);
        return true;
      },
      child: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: SizedBox(
                        width: 200,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                print("back tapped");
                                setState(() {
                                  if (selectedMonth > 0) {
                                    selectedMonth -= 1;
                                    filterExpenseListByMonth();
                                  }
                                });
                              },
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.blue,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                              child: Text(months[selectedMonth]),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedMonth < months.length - 1) {
                                    selectedMonth += 1;
                                    filterExpenseListByMonth();
                                  }
                                });

                                print("farwared tapped");
                              },
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: GestureDetector(
                        onTap: () {
                          print("Add Data");
                          showDialogForALlUser(context);
                        },
                        child: Container(
                          width: 120,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.blue[300],
                              borderRadius: BorderRadius.circular(8)),
                          child: const Center(
                            child: Text("Add Expenses"),
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
                filterredExpenses.expenseModel.isNotEmpty
                    ? Expanded(
                        // height: MediaQuery.of(context).size.height -
                        //     AppBar().preferredSize.height -
                        //     MediaQuery.of(context).padding.top -
                        //     MediaQuery.of(context).padding.bottom -
                        //     152,
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: filterredExpenses.expenseModel.length,
                            itemBuilder: (BuildContext context, int index) {
                              return expenseListWidget(index);
                            }),
                      )
                    : const Column(
                        children: [
                          SizedBox(
                            height: 120,
                          ),
                          Text(
                            "No Data",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ],
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  SizedBox expenseListWidget(int index) {
    return SizedBox(
        height: 130,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.blue),
                borderRadius: BorderRadius.circular(5)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          filterredExpenses.expenseModel[index].expenseName,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            // color: Colors.brown[100],
                            child: GestureDetector(
                              onTap: () {
                                print("Update... Tapped");
                                expenseAmountTextField.text = filterredExpenses
                                    .expenseModel[index].amount
                                    .toString();
                                expenseNameTextField.text = filterredExpenses
                                    .expenseModel[index].expenseName;
                                dropDonwPaymentMode = filterredExpenses
                                    .expenseModel[index].paymentMode;
                                dropDownExpenseType = filterredExpenses
                                    .expenseModel[index].expenseType;
                                showDialogForALlUser(context,
                                    isUpdate: true,
                                    dateID: filterredExpenses
                                        .expenseModel[index].date);
                              },
                              child: const ImageIcon(
                                AssetImage("assets/images/UpdateImage.png"),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: SizedBox(
                              width: 25,
                              height: 25,
                              // color: Colors.brown[100],
                              child: GestureDetector(
                                onTap: () {
                                  print("Delete Tapped");

                                  showAlertDialogOkButotn(context, "Delete",
                                      "Do you really want to delete selected Expense?",
                                      isDelete: true,
                                      dateId: filterredExpenses
                                          .expenseModel[index].date);
                                },
                                child: const ImageIcon(
                                  AssetImage("assets/images/DeleteImage.png"),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Text(
                    "Amount: ${filterredExpenses.expenseModel[index].amount}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  Text(
                    "Date: ${filterredExpenses.expenseModel[index].date}",
                    style: const TextStyle(color: Colors.blueGrey),
                  ),
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        Text(
                          "Mode: ${filterredExpenses.expenseModel[index].paymentMode}",
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                        const Spacer(),
                        Text(
                          "Expense Type: ${filterredExpenses.expenseModel[index].expenseType}",
                          style: const TextStyle(color: Colors.blueGrey),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  showDialogForALlUser(BuildContext context,
      {bool isUpdate = false, String dateID = ""}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    //color: Colors.grey,
                  ),
                  height: 370,
                  width: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                              controller: expenseNameTextField,
                              textAlign: TextAlign.start,
                              decoration: const InputDecoration(
                                hintText: "Expense Name",
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                              controller: expenseAmountTextField,
                              textAlign: TextAlign.start,
                              keyboardType: Platform.isIOS
                                  ? const TextInputType.numberWithOptions(
                                      signed: true, decimal: true)
                                  : TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,4}')),
                              ],
                              decoration: const InputDecoration(
                                hintText: "Expense Amount",
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 50,
                            child: Row(children: [
                              const Text("Payment Mode"),
                              const SizedBox(
                                width: 5,
                              ),
                              DropdownMenu<String>(
                                initialSelection: dropDonwPaymentMode,
                                onSelected: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    dropDonwPaymentMode = value!;
                                  });
                                },
                                dropdownMenuEntries: paymentMode
                                    .map<DropdownMenuEntry<String>>(
                                        (String value) {
                                  return DropdownMenuEntry<String>(
                                      value: value, label: value);
                                }).toList(),
                              )
                            ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 50,
                            child: Row(children: [
                              const Text("Expense Type"),
                              const SizedBox(
                                width: 10,
                              ),
                              DropdownMenu<String>(
                                width: 150,
                                initialSelection: dropDownExpenseType,
                                onSelected: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    dropDownExpenseType = value!;
                                  });
                                },
                                dropdownMenuEntries: expenseType
                                    .map<DropdownMenuEntry<String>>(
                                        (String value) {
                                  return DropdownMenuEntry<String>(
                                      value: value, label: value);
                                }).toList(),
                              )
                            ]),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    print("Dismiss");

                                    expenseAmountTextField.text = "";
                                    expenseNameTextField.text = "";
                                    dropDonwPaymentMode = paymentMode.first;
                                    dropDownExpenseType = expenseType.first;
                                  },
                                  child: Container(
                                    width: 110,
                                    decoration: BoxDecoration(
                                        color: Colors.blue[300],
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Center(
                                      child: Text("Dismiss"),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: GestureDetector(
                                  onTap: () {
                                    print("Add Data $dateID");
                                    saveDataInDB(context, dateID: dateID);
                                  },
                                  child: Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                        color: Colors.blue[300],
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Center(
                                      child: Text(
                                        "${isUpdate ? "Update" : "Add"} Expense",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )));
        });
  }

  void saveDataInDB(BuildContext context, {String dateID = ""}) {
    var expenseName = expenseNameTextField.text;
    var expenseAmount = expenseAmountTextField.text;

    if (expenseName == "") {
      showAlertDialogOkButotn(
          context, "Expense Name", "Expense name should not be blank",
          isDelete: true);
    } else if (expenseAmount == "") {
      showAlertDialogOkButotn(
          context, "Expense Amount", "Expense amount should not be blank");
    } else {
      var count = expenses.expenseModel.length;

      DateTime now = DateTime.now();
      String formattedDate = DateFormat(dateFormattedString).format(now);

      double inDouble = double.parse(expenseAmount);
      String inString = inDouble.toStringAsFixed(2);
      double inDouble2 = double.parse(inString);

//'dd-MM-yyyy hh:mm:ss'; '22-10-2022 09:34:45'
      var newExpense = ExpenseModelElement(
          id: "${count + 1}",
          date: dateID == "" ? formattedDate : dateID,
          expenseName: expenseName,
          amount: inDouble2,
          expenseType: dropDownExpenseType,
          paymentMode: dropDonwPaymentMode);

      if (dateID != "") {
        for (int i = 0; i < expenses.expenseModel.length; i++) {
          if (expenses.expenseModel[i].date != dateID) continue;
          expenses.expenseModel[i] = newExpense;
          break;
        }
      } else {
        expenses.expenseModel.add(newExpense);
      }

      SharedPreferencesSaveRetrieve.saveUsersDataToLocalStorage(
          expenses, widget.userID);

      expenseAmountTextField.text = "";
      expenseNameTextField.text = "";
      dropDonwPaymentMode = paymentMode.first;
      dropDownExpenseType = expenseType.first;
      getExpenses();

      Navigator.pop(context);
    }

//SharedPreferencesSaveRetrieve.saveUsersDataToLocalStorage(data, userID)
  }

  void showAlertDialogOkButotn(
      BuildContext context, String title, String message,
      {String dateId = "", bool isDelete = false}) {
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

                            ExpenseModelElement? elemetFound;
                            for (var element in expenses.expenseModel) {
                              if (dateId == element.date) {
                                elemetFound = element;
                              }
                            }
                            if (elemetFound != null) {
                              setState(() {
                                expenses.expenseModel.remove(elemetFound);
                                filterredExpenses.expenseModel
                                    .remove(elemetFound);
                              });
                              SharedPreferencesSaveRetrieve
                                  .saveUsersDataToLocalStorage(
                                      expenses, widget.userID);
                            }
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

  int getMonthName() {
    DateTime now = DateTime.now();

    String monthNumber = DateFormat("MM").format(now);
    print("monthName $monthNumber");
    return int.parse(monthNumber) - 1;
  }

  int getYear() {
    DateTime now = DateTime.now();

    String year = DateFormat("yyyy").format(now);
    print("year $year");
    return int.parse(year);
  }

  int parseStingTODateAndGetMonth(String dateString) {
    DateTime dateNow = DateFormat(dateFormattedString).parse(dateString);

    String monthNumber = DateFormat("MM").format(dateNow);
    print("monthName $monthNumber");
    return int.parse(monthNumber);
  }

  int parseStringToDateAndGetYear(String dateString) {
    DateTime dateNow = DateFormat(dateFormattedString).parse(dateString);

    String monthNumber = DateFormat("yyyy").format(dateNow);
    print("monthName $monthNumber");
    return int.parse(monthNumber);
  }

  filterExpenseListByMonth() {
    List<ExpenseModelElement> filterd = [];

    for (var element in expenses.expenseModel) {
      int monthNumber = parseStingTODateAndGetMonth(element.date);
      int year = parseStringToDateAndGetYear(element.date);
      if ((monthNumber == selectedMonth + 1) && year == getYear()) {
        filterd.add(element);
      }
    }

    setState(() {
      filterredExpenses.expenseModel = filterd;
    });
  }
}
