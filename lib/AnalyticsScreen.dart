import 'package:expensemanager/ExpenseModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class AlalyticsScreen extends StatefulWidget {
  final String userID;
  const AlalyticsScreen(this.userID, {super.key});

  @override
  State<AlalyticsScreen> createState() => _AlalyticsScreenState();
}

class _AlalyticsScreenState extends State<AlalyticsScreen> {
  ExpenseModel allExpenses = ExpenseModel(expenseModel: []);
  ExpenseModel filterredExpenses = ExpenseModel(expenseModel: []);
  String dateFormattedString = 'dd-MM-yyyy hh:mm:ss';
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

  String totalExpenses = "";
  int currentYear = 2024;
  String totalExpensesCurrent = "";

  int selectedMonth = 1;

  Map<String, double> analyticsMapData = {
    "No Data": 0,
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      selectedMonth = getCurrentMonthNumber();
    });
    getExpenses();
  }

  getExpenses() {
    SharedPreferencesSaveRetrieve.retrievesUsersDataFromLocalStorage(
            widget.userID)
        .then((value) {
      setState(() {
        allExpenses = value;
        currentYear = getYear();

        filterExpenseListByMonth();
      });

      double totEx = 0.0;
      for (var element in allExpenses.expenseModel) {
        if (parseStringToDateAndGetYear(element.date) == currentYear) {
          totEx = totEx + element.amount;
        }
      }
      setState(() {
        totalExpensesCurrent = "$totEx";
      });
    });
  }

  updateAnalyticsMapData() {
    Map<String, double> updatedMapData = {};

    if (filterredExpenses.expenseModel.isEmpty) {
      analyticsMapData = {
        "No Data": 0,
      };

      setState(() {
        totalExpenses = "0.0";
      });
      return;
    }

    double expenseAmt = 0.0;
    for (var element in filterredExpenses.expenseModel) {
      double expenseAmount = updatedMapData[element.expenseType] ?? 0;

      expenseAmt = expenseAmt + element.amount;
      updatedMapData[element.expenseType] = expenseAmount + element.amount;
    }

    setState(() {
      analyticsMapData = updatedMapData;
      totalExpenses = "$expenseAmt";
    });

    print("analyticsMapData $analyticsMapData");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: SizedBox(
                    width: 180,
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
                const Text(
                  "Total Expenses",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 10,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: Text(
                    totalExpenses,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: PieChart(
              dataMap: analyticsMapData,
              animationDuration: const Duration(milliseconds: 800),
              chartLegendSpacing: 60,
              chartRadius: MediaQuery.of(context).size.width / 3.0,
              //colorList: colorList,
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              ringStrokeWidth: 36,
              //centerText: "HYBRID",
              legendOptions: const LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.bottom,
                showLegends: true,
                legendShape: BoxShape.rectangle,
                legendTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              chartValuesOptions: const ChartValuesOptions(
                //showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: false,
                showChartValuesOutside: true,
                decimalPlaces: 1,
              ),
              // gradientList: ---To add gradient colors---
              // emptyColorGradient: ---Empty Color gradient---
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 25),
            child: Text(
              "Total Expenses in $currentYear is: $totalExpensesCurrent",
              style: const TextStyle(color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  int getCurrentMonthNumber() {
    DateTime now = DateTime.now();

    String monthNumber = DateFormat("MM").format(now);
    print("monthName $monthNumber");
    return int.parse(monthNumber) - 1;
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

  int getYear() {
    DateTime now = DateTime.now();

    String year = DateFormat("yyyy").format(now);
    print("year $year");
    return int.parse(year);
  }

  filterExpenseListByMonth() {
    List<ExpenseModelElement> filterd = [];
    for (var element in allExpenses.expenseModel) {
      int monthNumber = parseStingTODateAndGetMonth(element.date);
      int year = parseStringToDateAndGetYear(element.date);
      if ((monthNumber == selectedMonth + 1) && year == getYear()) {
        filterd.add(element);
      }
    }

    setState(() {
      filterredExpenses.expenseModel = filterd;
    });

    updateAnalyticsMapData();
  }
}
