import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'balance.dart';
import 'dbhelper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Balance Management',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int? selectedId;
  bool selectedI = true;
  bool selectedE = false;
  int sumIncome = 0;
  int sumExpense = 0;

  int tabIndex = 1;
  late TabController tabController =
      TabController(length: 3, vsync: this, initialIndex: tabIndex);

  @override
  Widget build(BuildContext context) {
    final TextEditingController catController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEE5007),
        elevation: 0,
        title: const Center(
          child: Text('Balance Management'),
        ),
      ),
      bottomNavigationBar: bottomNav(tabIndex, tabController),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                Column(children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Choose:',
                        style: TextStyle(color: Colors.red),
                      ),
                      ChoiceChip(
                        label: Text(
                          'Income',
                          style: TextStyle(
                              color: selectedI ? Colors.white : Colors.black),
                        ),
                        selected: selectedI,
                        selectedColor: Colors.red,
                        onSelected: (val) {
                          selectedI = !selectedI;
                          selectedE = !selectedE;
                          //print('Income: $selectedI and Expense: $selectedE');
                          setState(() {});
                        },
                      ),
                      ChoiceChip(
                        label: Text(
                          'Expense',
                          style: TextStyle(
                              color: !selectedI ? Colors.white : Colors.black),
                        ),
                        selected: selectedE,
                        selectedColor: Colors.red,
                        onSelected: (val) {
                          selectedI = !selectedI;
                          selectedE = !selectedE;
                          //print('Income: $selectedI and Expense: $selectedE');
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: catController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Source',
                      hintText: 'Source of income or expense i.e, 250',
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: amountController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Amount',
                      hintText: 'Amount in Taka i.e, 250',
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      String formattedDate =
                          DateFormat('kk:mm:ss \n EEE d MMM').format(now);
                      String amount = amountController.text;
                      String category = catController.text;
                      if (amount != '' && category != '') {
                        bool type = false;
                        if (selectedI) {
                          type = true;
                        } else {
                          type = false;
                        }
                        await DatabaseHelper.instance.addTransactions(
                          Balance(
                            amount: int.parse(amount),
                            category: category,
                            ctime: formattedDate,
                            type: type ? 'Income' : 'Expense',
                          ),
                        );

                        Get.snackbar(
                          type
                              ? 'Income Added Successfully!'
                              : 'Expense Added Successfully!',
                          'Source is $category and balance is $amount',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        amountController.text = '';
                        catController.text = '';
                      } else {
                        Get.snackbar(
                            'Error', 'Source and amount can\'t be blank.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                      }

                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    icon: const Icon(Icons.cloud),
                    label: const Text(
                      'Add Income/Expense',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.red,
                      onSurface: Colors.grey,
                    ),
                  ),
                ])
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            //color: Colors.red,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Card(
                        elevation: 10,
                        color: Colors.deepOrangeAccent,
                        child: SizedBox(
                          //padding: const EdgeInsets.all(8.0),
                          height: MediaQuery.of(context).size.height / 5,
                          width: MediaQuery.of(context).size.width - 9,
                          child: FutureBuilder(
                              future:
                                  DatabaseHelper.instance.getAllTransaction(),
                              builder: (context,
                                  AsyncSnapshot<List<Balance>> snapshot) {
                                int x = 0;
                                int y = 0;
                                if (snapshot.hasData) {
                                  snapshot.data!.map((e) {
                                    if (e.type == 'Income') {
                                      x = x + e.amount;
                                    } else {
                                      y = y + e.amount;
                                    }
                                  });
                                  for (var e in snapshot.data!) {
                                    if (e.type == 'Income') {
                                      x = x + e.amount;
                                    } else {
                                      y = y + e.amount;
                                    }
                                  }
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Card(
                                          color: Colors.deepOrangeAccent[400],
                                          elevation: 0,
                                          child: SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                6,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                18,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                const Text(
                                                  'Income',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                ),
                                                Text(
                                                  '$x BDT',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Card(
                                          color: Colors.deepOrangeAccent[400],
                                          elevation: 0,
                                          child: SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                6,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                18,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                const Text(
                                                  'Expense',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                ),
                                                Text(
                                                  '$y BDT',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 10,
                          width: MediaQuery.of(context).size.width - 9,
                          child: Card(
                            color: Colors.red[600],
                            elevation: 5,
                            child: FutureBuilder(
                                future:
                                    DatabaseHelper.instance.getAllTransaction(),
                                builder: (context,
                                    AsyncSnapshot<List<Balance>> snapshot) {
                                  int x = 0;
                                  int y = 0;
                                  if (snapshot.hasData) {
                                    snapshot.data!.map((e) {
                                      if (e.type == 'Income') {
                                        x = x + e.amount;
                                      } else {
                                        y = y + e.amount;
                                      }
                                    });
                                    for (var e in snapshot.data!) {
                                      if (e.type == 'Income') {
                                        x = x + e.amount;
                                      } else {
                                        y = y + e.amount;
                                      }
                                    }
                                  }
                                  return Center(
                                    child: Text(
                                      'Available Credit: ${x - y} BDT',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Income / Expense ',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 153, 99, 99),
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.normal),
                            ),
                            TextButton.icon(
                              label: const Text(
                                'Sort By',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 153, 99, 99),
                                    fontSize: 16,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.normal),
                              ),
                              icon: const Icon(
                                Icons.sort_outlined,
                                color: Color.fromARGB(255, 153, 99, 99),
                              ),
                              onPressed: () {
                                // DateTime now = DateTime.now();
                                // String formattedDate =
                                //     DateFormat('kk:mm:ss \n EEE d MMM').format(now);
                                // Get.snackbar('Current Time', formattedDate);
                              },
                            )
                          ],
                        ),
                        Container(
                          color: Colors.redAccent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Text(
                                'ID',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Name',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Amount',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Type',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Date',
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        // List of Blanance Data Table

                        FutureBuilder<List<Balance>>(
                            future: DatabaseHelper.instance.getAllTransaction(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Balance>> snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: Text('Loading...'));
                              }
                              return snapshot.data!.isEmpty
                                  ? const Center(
                                      child: Text('No Source in List.'))
                                  : ListView(
                                      shrinkWrap: true,
                                      physics: const ScrollPhysics(),
                                      children: snapshot.data!.map((src) {
                                        return Center(
                                          child: InkWell(
                                            onLongPress: () {
                                              Get.bottomSheet(Container(
                                                height: 120,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Colors.white),
                                                //height: 100,
                                                margin:
                                                    const EdgeInsets.all(30),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Text(
                                                          'Name: ${src.category}',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                        Text(
                                                          'Amount: ${src.amount} BDT',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .red),
                                                        )
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          // ignore: sort_child_properties_last
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                          style: TextButton
                                                              .styleFrom(
                                                            primary:
                                                                Colors.white,
                                                            backgroundColor:
                                                                Colors.green,
                                                            onSurface:
                                                                Colors.grey,
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            var id = src.id;
                                                            DatabaseHelper
                                                                .instance
                                                                .removeTransactions(
                                                                    id!);
                                                            Get.snackbar(
                                                                src.category,
                                                                src.amount
                                                                    .toString(),
                                                                snackPosition:
                                                                    SnackPosition
                                                                        .BOTTOM);
                                                            setState(() {});
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          // ignore: sort_child_properties_last
                                                          child: const Text(
                                                              'Delete'),
                                                          style: TextButton
                                                              .styleFrom(
                                                            primary:
                                                                Colors.white,
                                                            backgroundColor:
                                                                Colors.red,
                                                            onSurface:
                                                                Colors.grey,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ));
                                            },
                                            child: Card(
                                              color: Colors.white,
                                              child: Container(
                                                color: Colors.white,
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      src.id.toString(),
                                                      style: TextStyle(
                                                          color: src.type ==
                                                                  'Income'
                                                              ? Colors.green
                                                              : Colors.red),
                                                    ),
                                                    Text(src.category,
                                                        style: TextStyle(
                                                            color: src.type ==
                                                                    'Income'
                                                                ? Colors.green
                                                                : Colors.red)),
                                                    Text(src.amount.toString(),
                                                        style: TextStyle(
                                                            color: src.type ==
                                                                    'Income'
                                                                ? Colors.green
                                                                : Colors.red)),
                                                    Text(
                                                        src.type == 'Income'
                                                            ? 'I'
                                                            : 'E',
                                                        style: TextStyle(
                                                            color: src.type ==
                                                                    'Income'
                                                                ? Colors.green
                                                                : Colors.red)),
                                                    Text(src.ctime,
                                                        style: TextStyle(
                                                            color: src.type ==
                                                                    'Income'
                                                                ? Colors.green
                                                                : Colors.red))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          /* Add Income Expense Source List */
          Container(
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: const [
                    Center(
                      child: Text(
                        'Coming soon...',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      /* floatingActionButton: TextButton.icon(
        onPressed: () {},
        icon: const Icon(
          Icons.person_add,
          color: Colors.white,
          size: 32,
        ),
        label: const Text(
          'Add Customer',
          style: TextStyle(color: Colors.white),
        ),
        //TextButton Style Changing
        style: TextButton.styleFrom(
          primary: Colors.red,
          backgroundColor: Colors.red[700],
          onSurface: Colors.red,
          elevation: 10,
        ),
      ), */
    );
  }

  List colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.orangeAccent
  ];
}

Widget bottomNav(int tabIndex, TabController tabController) {
  return CircleNavBar(
    activeIcons: const [
      Center(child: FaIcon(FontAwesomeIcons.receipt, color: Color(0xffEE5007))),
      Center(child: FaIcon(FontAwesomeIcons.inbox, color: Color(0xffEE5007))),
      Icon(Icons.add, color: Color(0xffEE5007)),
    ],
    inactiveIcons: const [
      Center(child: FaIcon(FontAwesomeIcons.receipt, color: Color(0xffEE5007))),
      Center(child: FaIcon(FontAwesomeIcons.inbox, color: Color(0xffEE5007))),
      Icon(Icons.add, color: Color(0xffEE5007)),
    ],
    color: Colors.white,
    height: 60,
    circleWidth: 60,
    initIndex: tabIndex,
    onChanged: (v) {
      tabIndex = v;
      tabController.animateTo(v);
      // setState(() {});
    },
    // tabCurve: ,
    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
    cornerRadius: const BorderRadius.only(
      topLeft: Radius.circular(8),
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(24),
      bottomLeft: Radius.circular(24),
    ),
    shadowColor: Colors.deepPurple,
    elevation: 10,
  );
}

// Buyer Seller and Send SMS Icon
Widget afterCardLabel(BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Income / Expense ',
              style: TextStyle(
                  color: Color.fromARGB(255, 153, 99, 99),
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.normal),
            ),
            TextButton.icon(
              label: const Text(
                'Sort By',
                style: TextStyle(
                    color: Color.fromARGB(255, 153, 99, 99),
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal),
              ),
              icon: const Icon(
                Icons.sort_outlined,
                color: Color.fromARGB(255, 153, 99, 99),
              ),
              onPressed: () {
                // DateTime now = DateTime.now();
                // String formattedDate =
                //     DateFormat('kk:mm:ss \n EEE d MMM').format(now);
                // Get.snackbar('Current Time', formattedDate);
              },
            )
          ],
        ),
        Container(
          color: Colors.redAccent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text(
                'ID',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Name',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Amount',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Type',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Date',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
        // List of Blanance Data Table

        FutureBuilder<List<Balance>>(
            future: DatabaseHelper.instance.getAllTransaction(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Balance>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: Text('Loading...'));
              }
              return snapshot.data!.isEmpty
                  ? const Center(child: Text('No Source in List.'))
                  : ListView(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      children: snapshot.data!.map((src) {
                        return Center(
                          child: InkWell(
                            onLongPress: () {
                              Get.bottomSheet(Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white),
                                //height: 100,
                                margin: const EdgeInsets.all(30),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        const Text(
                                          'Name:',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          src.category,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        const Text(
                                          'Amount:',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          src.amount.toString(),
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        TextButton(
                                          onPressed: () {},
                                          child: const Text('Cancel'),
                                          style: TextButton.styleFrom(
                                            primary: Colors.white,
                                            backgroundColor: Colors.green,
                                            onSurface: Colors.grey,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            var id = src.id;
                                            DatabaseHelper.instance
                                                .removeTransactions(id!);
                                            Get.snackbar(src.category,
                                                src.amount.toString(),
                                                snackPosition:
                                                    SnackPosition.BOTTOM);
                                          },
                                          child: const Text('Delete'),
                                          style: TextButton.styleFrom(
                                            primary: Colors.white,
                                            backgroundColor: Colors.red,
                                            onSurface: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ));
                            },
                            child: Card(
                              color: Colors.white,
                              child: Container(
                                color: Colors.white,
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      src.id.toString(),
                                      style: TextStyle(
                                          color: src.type == 'income'
                                              ? Colors.green
                                              : Colors.red),
                                    ),
                                    Text(src.category,
                                        style: TextStyle(
                                            color: src.type == 'income'
                                                ? Colors.green
                                                : Colors.red)),
                                    Text(src.amount.toString(),
                                        style: TextStyle(
                                            color: src.type == 'income'
                                                ? Colors.green
                                                : Colors.red)),
                                    Text(src.type == 'income' ? 'I' : 'E',
                                        style: TextStyle(
                                            color: src.type == 'income'
                                                ? Colors.green
                                                : Colors.red)),
                                    Text(src.ctime,
                                        style: TextStyle(
                                            color: src.type == 'income'
                                                ? Colors.green
                                                : Colors.red))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
            }),
      ],
    ),
  );
}
