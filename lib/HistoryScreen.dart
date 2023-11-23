import 'package:expensemanager/ExpenseModel.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final String userID;
  const HistoryScreen(this.userID, {super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String dateFormattedString = 'dd-MM-yyyy hh:mm:ss';

  int selectedMonth = 1;
  ExpenseModel expenses = ExpenseModel(expenseModel: []);

  ExpenseModel filterredExpenses = ExpenseModel(expenseModel: []);
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

  int previousYear = 2022;
  bool isPieChart = false;

  String totalExpenses = "0.0";
  String totalExpensesPrevious = "0.0";
  Map<String, double> analyticsMapData = {
    "No Data": 0,
  };

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

        previousYear = getYear() - 1;

        double yearExpenses = 0.0;

        for (var element in expenses.expenseModel) {
          if (parseStringToDateAndGetYear(element.date) == previousYear) {
            yearExpenses = yearExpenses + element.amount;
          }
        }

        setState(() {
          totalExpensesPrevious = "$yearExpenses";
        });

        filterExpenseListByMonth();
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
        appBar: AppBar(
          title: const Text("History Analysis"),
          backgroundColor: Colors.blue[400],
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            SizedBox(
              height: 50,
              child: Row(children: [
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
                          child: Text("${months[selectedMonth]} $previousYear"),
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
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Text(
                    "${isPieChart ? "Hide" : "Show"} Chart",
                    style: const TextStyle(color: Colors.cyan),
                  ),
                ),
                Switch(
                  value: isPieChart,
                  onChanged: (bool value) {
                    setState(() {
                      isPieChart = value;
                    });
                  },
                ),
                const SizedBox(
                  width: 10,
                )
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Total Expenses in ${months[selectedMonth]} is: $totalExpenses",
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Total Expenses in $previousYear is: $totalExpensesPrevious",
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ),
            !isPieChart
                ? filterredExpenses.expenseModel.isNotEmpty
                    ? Expanded(
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
                      )
                : Padding(
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
          ],
        ));
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
      if ((monthNumber == selectedMonth + 1) && year == previousYear) {
        filterd.add(element);
      }
    }

    setState(() {
      filterredExpenses.expenseModel = filterd;
    });

    updateAnalyticsMapData();
  }
}
