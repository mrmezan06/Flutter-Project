import 'dart:async';
import 'dart:io';

import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:d_chart/d_chart.dart';
import 'package:intl/intl.dart';

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
  int tabIndex = 1;
  late TabController tabController =
      TabController(length: 3, vsync: this, initialIndex: tabIndex);

  String srcName = '';

  List<Map<String, dynamic>> mydata = [];
  List<Balance> mydataDB = [];
  static int x = 0;
  getSum() async {
    await DatabaseHelper.instance
        .getAllBalList()
        .then((e) => e.map((e) => x + e.amount));
    setState(() {
      // print(x);
    });
  }

  _generateData() async {
    mydataDB = await DatabaseHelper.instance.getAllBalList();
    if (mydataDB.isNotEmpty) {
      mydata = mydataDB.map((e) {
        //print(e.toMap());
        return {
          'domain': e.id,
          'measure': (e.amount / x) * 100,
        };
      }).toList();
    } else {
      return [
        {'domain': 'Flutter', 'measure': 28},
        {'domain': 'React Native', 'measure': 27},
        {'domain': 'Ionic', 'measure': 20},
        {'domain': 'Cordova', 'measure': 15},
      ];
    }
  }

  @override
  void initState() {
    _generateData();
    getSum();
    //print(x);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController incomeTEController = TextEditingController();
    final TextEditingController incomeSrcTEController = TextEditingController();
    final TextEditingController expenseTEController = TextEditingController();
    final TextEditingController expenseSrcTEController =
        TextEditingController();

    // String dropdownvalue = 'Mother\'s in Law'.obs();

// List of items in our dropdown menu

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
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Income Source:',
                          style: TextStyle(fontSize: 20),
                        ),
                        FutureBuilder<List<LsSource>>(
                            future: DatabaseHelper.instance.getIncomeSrcList(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<LsSource>> snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: Text('Loading...'));
                              }
                              return snapshot.data!.isEmpty
                                  ? const Center(
                                      child: Text('No Source in List.'))
                                  : TextButton.icon(
                                      onPressed: () async {
                                        srcName =
                                            await Get.bottomSheet(ListView(
                                          shrinkWrap: true,
                                          physics: const ScrollPhysics(),
                                          children: snapshot.data!.map((src) {
                                            return Center(
                                              child: Card(
                                                color: selectedId == src.id
                                                    ? Colors.white70
                                                    : Colors.white,
                                                child: ListTile(
                                                  leading:
                                                      src.category == 'income'
                                                          ? const Text('I')
                                                          : const Text('E'),
                                                  title: Text(src.name),
                                                  trailing: Text(
                                                    src.category,
                                                    style: TextStyle(
                                                        color: src.category ==
                                                                'income'
                                                            ? Colors.green
                                                            : Colors.red),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(
                                                        context, src.name);
                                                  },
                                                  onLongPress: () {},
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ));
                                      },
                                      icon: const Icon(Icons.list),
                                      label: const Text('Source List'));
                            }),
                      ],
                    ),
                    TextField(
                      controller: incomeTEController,
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
                      height: 10,
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        if (srcName != '') {
                          DateTime now = DateTime.now();
                          String formattedDate =
                              DateFormat('kk:mm:ss \n EEE d MMM').format(now);
                          await DatabaseHelper.instance.addIncome(
                            Balance(
                              amount: int.parse(incomeTEController.text),
                              category: srcName,
                              ctime: formattedDate,
                              type: 'income',
                            ),
                          );

                          Get.snackbar(
                            'Income Added Successfully!',
                            'Income category $srcName, type income and balance is ${incomeTEController.text}',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          incomeTEController.text = '';
                          srcName = '';
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                      },
                      icon: const Icon(Icons.cloud),
                      label: const Text(
                        'Add Income',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.red,
                        onSurface: Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Expense
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Expense Source:',
                          style: TextStyle(fontSize: 20),
                        ),
                        FutureBuilder<List<LsSource>>(
                            future: DatabaseHelper.instance.getExpenseSrcList(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<LsSource>> snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: Text('Loading...'));
                              }
                              return snapshot.data!.isEmpty
                                  ? const Center(
                                      child: Text('No Source in List.'))
                                  : TextButton.icon(
                                      onPressed: () async {
                                        srcName =
                                            await Get.bottomSheet(ListView(
                                          shrinkWrap: true,
                                          physics: const ScrollPhysics(),
                                          children: snapshot.data!.map((src) {
                                            return Center(
                                              child: Card(
                                                color: selectedId == src.id
                                                    ? Colors.white70
                                                    : Colors.white,
                                                child: ListTile(
                                                  leading:
                                                      src.category == 'income'
                                                          ? const Text('I')
                                                          : const Text('E'),
                                                  title: Text(src.name),
                                                  trailing: Text(
                                                    src.category,
                                                    style: TextStyle(
                                                        color: src.category ==
                                                                'income'
                                                            ? Colors.green
                                                            : Colors.red),
                                                  ),
                                                  onTap: () {
                                                    Get.snackbar(
                                                        src.category
                                                            .toUpperCase(),
                                                        src.name,
                                                        snackPosition:
                                                            SnackPosition
                                                                .BOTTOM);
                                                    Navigator.pop(
                                                        context, src.name);
                                                  },
                                                  onLongPress: () {},
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ));
                                        //print(srcName);
                                      },
                                      icon: const Icon(Icons.list),
                                      label: const Text('Source List'));
                            }),
                      ],
                    ),
                    TextField(
                      controller: expenseTEController,
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
                      height: 10,
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        if (srcName != '') {
                          DateTime now = DateTime.now();
                          String formattedDate =
                              DateFormat('kk:mm:ss \n EEE d MMM').format(now);
                          await DatabaseHelper.instance.addIncome(
                            Balance(
                              amount: int.parse(expenseTEController.text),
                              category: srcName,
                              ctime: formattedDate,
                              type: 'expense',
                            ),
                          );

                          Get.snackbar(
                            'Expense Added Successfully!',
                            'Expense category $srcName, type expense and balance is ${expenseTEController.text}',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          expenseTEController.text = '';
                          srcName = '';
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                      },
                      icon: const Icon(Icons.cloud),
                      label: const Text(
                        'Add Expense',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.red,
                        onSurface: Colors.grey,
                      ),
                    ),
                  ],
                ),
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
                        color: const Color(0xffff0000).withOpacity(0.1),
                        child: SizedBox(
                            //padding: const EdgeInsets.all(8.0),
                            height: MediaQuery.of(context).size.height / 5,
                            width: MediaQuery.of(context).size.width - 9,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: AspectRatio(
                                aspectRatio: 5,
                                child: DChartPie(
                                  data: mydataDB.map((e) {
                                    return {
                                      'domain': e.category,
                                      //+ e.id.toString(),
                                      'measure': e.amount,
                                    };
                                  }).toList(),
                                  fillColor: (Map<String, dynamic> pieData,
                                      int? index) {
                                    int x = 0;
                                    if (index! > colors.length) {
                                      x = colors.length % index;
                                    } else {
                                      x = index;
                                    }
                                    return colors[x];
                                  },
                                  donutWidth: 20,
                                  pieLabel: (pieData, index) {
                                    String domain = pieData['domain'];
                                    // String name =
                                    //     domain.replaceAll(RegExp(r'[0-9]'), '');
                                    return "$domain: ${pieData['measure']}";
                                  },
                                  labelColor: Colors.white,
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                  Container(
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
                            future: DatabaseHelper.instance.getAllBalList(),
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
                                                        const Text(
                                                          'Name:',
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        Text(
                                                          src.category,
                                                          style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        const Text(
                                                          'Amount:',
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        Text(
                                                          src.amount.toString(),
                                                          style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                                                          child: const Text(
                                                              'Cancel'),
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
                                                                .removeIncome(
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
                                                                  'income'
                                                              ? Colors.green
                                                              : Colors.red),
                                                    ),
                                                    Text(src.category,
                                                        style: TextStyle(
                                                            color: src.type ==
                                                                    'income'
                                                                ? Colors.green
                                                                : Colors.red)),
                                                    Text(src.amount.toString(),
                                                        style: TextStyle(
                                                            color: src.type ==
                                                                    'income'
                                                                ? Colors.green
                                                                : Colors.red)),
                                                    Text(
                                                        src.type == 'income'
                                                            ? 'I'
                                                            : 'E',
                                                        style: TextStyle(
                                                            color: src.type ==
                                                                    'income'
                                                                ? Colors.green
                                                                : Colors.red)),
                                                    Text(src.ctime,
                                                        style: TextStyle(
                                                            color: src.type ==
                                                                    'income'
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
                  children: [
                    TextField(
                      controller: incomeSrcTEController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Income Source',
                        hintText: 'Earning area ie., Gift, Salary etc.',
                        contentPadding: EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        /* Adding to the DB */
                        await DatabaseHelper.instance.add(
                          LsSource(
                              name: incomeSrcTEController.text,
                              category: 'income'),
                        );
                        Get.snackbar(
                          'Income Source',
                          incomeSrcTEController.text,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text(
                        'Add Income Source',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.red,
                        onSurface: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    /* Expense Source Add */
                    TextField(
                      controller: expenseSrcTEController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Expense Source',
                        hintText: 'Expense area ie., Gift, Food etc.',
                        contentPadding: EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        /* Adding to the DB */
                        await DatabaseHelper.instance.add(
                          LsSource(
                              name: expenseSrcTEController.text,
                              category: 'expense'),
                        );
                        FocusManager.instance.primaryFocus?.unfocus();
                        Get.snackbar(
                          'Expense Source',
                          expenseSrcTEController.text,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text(
                        'Add Expense Source',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.red,
                        onSurface: Colors.grey,
                      ),
                    ),
                    // Show Income Source List
                    const SizedBox(
                      height: 40,
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.document_scanner),
                      label: const Text(
                        'All Source List',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.red,
                        onSurface: Colors.grey,
                      ),
                    ),
                    FutureBuilder<List<LsSource>>(
                        future: DatabaseHelper.instance.getAllSrcList(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<LsSource>> snapshot) {
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
                                      child: Card(
                                        color: selectedId == src.id
                                            ? Colors.white70
                                            : Colors.white,
                                        child: ListTile(
                                          leading: src.category == 'income'
                                              ? const Text('I')
                                              : const Text('E'),
                                          title: Text(src.name),
                                          trailing: Text(
                                            src.category,
                                            style: TextStyle(
                                                color: src.category == 'income'
                                                    ? Colors.green
                                                    : Colors.red),
                                          ),
                                          onTap: () {
                                            // setState(() {
                                            //   if (selectedId == null) {
                                            //     textController.text =
                                            //         grocery.name;
                                            //     selectedId = grocery.id;
                                            //   } else {
                                            //     textController.text = '';
                                            //     selectedId = null;
                                            //   }
                                            // });
                                          },
                                          onLongPress: () {
                                            // setState(() {
                                            //   if (selectedId == null) {
                                            //     incomeSrcTEController.text =
                                            //         src.name;
                                            //     selectedId = src.id;
                                            //   } else {
                                            //     incomeSrcTEController.text = '';
                                            //     selectedId = null;
                                            //   }
                                            // });
                                            TextEditingController
                                                updateController =
                                                TextEditingController();
                                            if (selectedId == null) {
                                              updateController.text = src.name;
                                              selectedId = src.id;
                                            } else {
                                              updateController.text = '';
                                              selectedId = null;
                                            }

                                            Get.bottomSheet(Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color: Colors.white),
                                              //height: 100,
                                              margin: const EdgeInsets.all(30),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  TextField(
                                                    controller:
                                                        updateController,
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText:
                                                          'Expense Source',
                                                      hintText:
                                                          'Expense area ie., Gift, Food etc.',
                                                      contentPadding:
                                                          EdgeInsets.all(8),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      TextButton.icon(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  primary:
                                                                      Colors
                                                                          .red,
                                                                  onPrimary:
                                                                      Colors
                                                                          .red),
                                                          onPressed: () {
                                                            // Cancel Operation
                                                            Navigator.pop(
                                                                context);
                                                            selectedId = null;
                                                          },
                                                          icon: const Icon(
                                                            Icons.cancel,
                                                            color: Colors.white,
                                                          ),
                                                          label: const Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                      TextButton.icon(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  primary:
                                                                      Colors
                                                                          .red,
                                                                  onPrimary:
                                                                      Colors
                                                                          .red),
                                                          onPressed: () async {
                                                            // Update Operation
                                                            await DatabaseHelper
                                                                .instance
                                                                .update(LsSource(
                                                                    id:
                                                                        selectedId,
                                                                    name: updateController
                                                                        .text,
                                                                    category: src
                                                                        .category));
                                                            Get.snackbar(
                                                              'Source Updated',
                                                              updateController
                                                                  .text,
                                                              snackPosition:
                                                                  SnackPosition
                                                                      .BOTTOM,
                                                            );
                                                            updateController
                                                                .text = '';
                                                            selectedId = null;
                                                            setState(() {});
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          icon: const Icon(
                                                            Icons.cancel,
                                                            color: Colors.white,
                                                          ),
                                                          label: const Text(
                                                            'Update',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ));

                                            // setState(() {
                                            //   DatabaseHelper.instance
                                            //       .remove(grocery.id!);
                                            // });
                                          },
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                        }),
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
  // Widget incomeChart(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.all(16),
  //     child: AspectRatio(
  //       aspectRatio: 5,
  //       child: DChartPie(
  //         data: mydataDB.map((e) {
  //           return {
  //             'domain': e.category,
  //             //+ e.id.toString(),
  //             'measure': e.amount,
  //           };
  //         }).toList(),
  //         fillColor: (Map<String, dynamic> pieData, int? index) {
  //           int x = 0;
  //           if (index! > colors.length) {
  //             x = colors.length % index;
  //           } else {
  //             x = index;
  //           }
  //           return colors[x];
  //         },
  //         donutWidth: 20,
  //         pieLabel: (pieData, index) {
  //           String domain = pieData['domain'];
  //           String name = domain.replaceAll(RegExp(r'[0-9]'), '');
  //           return "$name: ${pieData['measure']}";
  //         },
  //         labelColor: Colors.white,
  //       ),
  //     ),
  //   );
  // }
}

/* Home Section */

/* Chart */

// bottom Navigation Bar
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
            future: DatabaseHelper.instance.getAllBalList(),
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
                                                .removeIncome(id!);
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

/* Home Section End */

/* Database Part */

/* Model Class */
class LsSource {
  final int? id;
  final String name;
  final String category;

  LsSource({this.id, required this.name, required this.category});

  factory LsSource.fromMap(Map<String, dynamic> json) =>
      LsSource(id: json['id'], name: json['name'], category: json['category']);

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'category': category};
  }
}

/* Balance Model */

class Balance {
  final int? id;
  final int amount;
  final String type;
  final String category;
  final String ctime;

  Balance(
      {this.id,
      required this.amount,
      required this.type,
      required this.category,
      required this.ctime});

  factory Balance.fromMap(Map<String, dynamic> json) => Balance(
      id: json['id'],
      amount: json['amount'],
      type: json['type'],
      category: json['category'],
      ctime: json['ctime']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'ctime': ctime
    };
  }
}

/* Database Create Class */
class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'incomesrc.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE incomesrc(
            id INTEGER PRIMARY KEY,
            name TEXT,
            category TEXT
        )
        ''');
    /*  db.execute('''
        DROP TABLE incomesrcs
        '''); */
    await db.execute('''
        CREATE TABLE balance(
            id INTEGER PRIMARY KEY,
            amount INTEGER,
            type TEXT,
            category TEXT,
            ctime TEXT
        )
''');
  }

  /* Get All Data of incomesrc table */
  Future<List<LsSource>> getAllSrcList() async {
    Database db = await instance.database;
    var incomesrcs = await db.query('incomesrc', orderBy: 'category');
    List<LsSource> incomesrcList = incomesrcs.isNotEmpty
        ? incomesrcs.map((c) => LsSource.fromMap(c)).toList()
        : [];
    return incomesrcList;
  }

/* Get all data filtered by income */
  Future<List<LsSource>> getIncomeSrcList() async {
    Database db = await instance.database;
    var incomesrcs = await db
        .query('incomesrc', where: 'category = ?', whereArgs: ['income']);
    List<LsSource> expensesrcList = incomesrcs.isNotEmpty
        ? incomesrcs.map((c) => LsSource.fromMap(c)).toList()
        : [];
    return expensesrcList;
  }

/* Get All Data filtered by expense */
  Future<List<LsSource>> getExpenseSrcList() async {
    Database db = await instance.database;
    var incomesrcs = await db
        .query('incomesrc', where: 'category = ?', whereArgs: ['expense']);
    List<LsSource> expensesrcList = incomesrcs.isNotEmpty
        ? incomesrcs.map((c) => LsSource.fromMap(c)).toList()
        : [];
    return expensesrcList;
  }

/* Add to the incomesrc Table */
  Future<int> add(LsSource incomesrc) async {
    Database db = await instance.database;
    return await db.insert('incomesrc', incomesrc.toMap());
  }

/* Remove data */
  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('incomesrc', where: 'id = ?', whereArgs: [id]);
  }

/* Update data */
  Future<int> update(LsSource incomesrc) async {
    Database db = await instance.database;
    return await db.update('incomesrc', incomesrc.toMap(),
        where: "id = ?", whereArgs: [incomesrc.id]);
  }

  /* Balance Table Operation */

/* Get All Data of income table */
  Future<List<Balance>> getAllBalList() async {
    Database db = await instance.database;
    var incomes = await db.query('balance', orderBy: 'id');
    List<Balance> incomeList = incomes.isNotEmpty
        ? incomes.map((c) => Balance.fromMap(c)).toList()
        : [];
    return incomeList;
  }

/* Get all data filtered by income */
  Future<List<Balance>> getIncomeList() async {
    Database db = await instance.database;
    var incomes =
        await db.query('balance', where: 'type = ?', whereArgs: ['income']);
    List<Balance> getIncomeList = incomes.isNotEmpty
        ? incomes.map((c) => Balance.fromMap(c)).toList()
        : [];
    return getIncomeList;
  }

/* Get All Data filtered by expense */
  Future<List<Balance>> getExpenseList() async {
    Database db = await instance.database;
    var incomes =
        await db.query('balance', where: 'type = ?', whereArgs: ['expense']);
    List<Balance> expenseList = incomes.isNotEmpty
        ? incomes.map((c) => Balance.fromMap(c)).toList()
        : [];
    return expenseList;
  }

/* Add to the income Table */
  Future<int> addIncome(Balance income) async {
    Database db = await instance.database;
    try {
      var prevBal = await db.query('balance',
          where: 'category = ?', whereArgs: [income.category], limit: 1);
      //print(prevBal.toString());
      Object? x = 0;
      x = prevBal[0]['amount'];
      int y = int.parse(x.toString());
      if (y > 0) {
        var id = prevBal[0]['id'];
        int pid = int.parse(id.toString());
        var type = income.type;
        var category = income.category;
        var ctime = income.ctime;
        Balance nBal = Balance(
          id: pid,
          amount: y + income.amount,
          category: category,
          ctime: ctime,
          type: type,
        );
        //print(y + income.amount);
        return await db.update('balance', nBal.toMap(),
            where: "id = ?", whereArgs: [nBal.id]);
      }
    } catch (e) {
      e.printError();
    }

    return await db.insert('balance', income.toMap());
  }

/* Remove data */
  Future<int> removeIncome(int id) async {
    Database db = await instance.database;
    return await db.delete('balance', where: 'id = ?', whereArgs: [id]);
  }

/* Update data */
  Future<int> updateIncome(Balance income) async {
    Database db = await instance.database;
    return await db.update('balance', income.toMap(),
        where: "id = ?", whereArgs: [income.id]);
  }
}
