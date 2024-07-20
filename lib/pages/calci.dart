import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_stonkd/components/my_button.dart';
import 'package:get_stonkd/components/my_textfield.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Calci extends StatefulWidget {
  final String symbol;
  Calci({super.key, required this.symbol});

  @override
  State<Calci> createState() => _CalciState();
}

class DailyData {
  final Map<String, Map<String, String>> timeSeries;

  DailyData({required this.timeSeries});

  factory DailyData.fromJson(Map<String, dynamic> json) {
    // Convert the dynamic map to Map<String, Map<String, String>>
    var timeSeriesJson = json['Time Series (Daily)'] as Map<String, dynamic>;
    var timeSeries = timeSeriesJson.map((key, value) {
      // Convert each value to Map<String, String>
      var dailyData = value as Map<String, dynamic>;
      return MapEntry(key, dailyData.map((k, v) => MapEntry(k, v.toString())));
    });

    return DailyData(
      timeSeries: timeSeries,
    );
  }

  String? getHighValueForDate(String date) {
    if (timeSeries.containsKey(date)) {
      return timeSeries[date]?['2. high'];
    } else {
      return '';
    }
  }

  String? getLowValueForDate(String date) {
    if (timeSeries.containsKey(date)) {
      return timeSeries[date]?['3. low'];
    } else {
      return '';
    }
  }
}

Future<DailyData> fetchData(String stock) async {
  // Specify the URL
  var url = Uri.parse(
      'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&outputsize=full&symbol=' +
          stock +
          '&apikey=QVFA4PKCG6TS3W24');

  // Make the GET request
  var response = await http.get(url);

  // Check if the request was successful
  if (response.statusCode == 200) {
    return DailyData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load suggestions');
  }
}

class _CalciState extends State<Calci> {
  DateTime? buyDate;
  DateTime? sellDate;

  final TextEditingController buyDateController = TextEditingController();
  final TextEditingController sellDateController = TextEditingController();

  bool returnpage = false;
  String highVal1 = '0.0';
  String lowVal1 = '0.0';
  String highVal2 = '0.0';
  String lowVal2 = '0.0';

  Future<void> _selectDate(BuildContext context, bool check) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (check) {
      if (picked != null && picked != buyDate) {
        setState(() {
          buyDate = picked;
          buyDateController.text = '${buyDate!.toLocal()}'.split(' ')[0];
        });
      }
    } else {
      if (picked != null && picked != sellDate) {
        setState(() {
          sellDate = picked;
          sellDateController.text = '${sellDate!.toLocal()}'.split(' ')[0];
        });
      }
    }
  }

  void showErrorMsg(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void returns() async {
    setState(() {
      if (buyDate != null &&
          sellDate != null &&
          quantity.text != '' &&
          buyDate!.isBefore(sellDate!)) {
        highVal1 = stockData?.timeSeries['${buyDate!.toLocal()}'.split(' ')[0]]
                ?['2. high'] ??
            '0.0';
        lowVal1 = stockData?.timeSeries['${buyDate!.toLocal()}'.split(' ')[0]]
                ?['3. low'] ??
            '0.0';
        highVal2 = stockData?.timeSeries['${sellDate!.toLocal()}'.split(' ')[0]]
                ?['2. high'] ??
            '0.0';
        lowVal2 = stockData?.timeSeries['${sellDate!.toLocal()}'.split(' ')[0]]
                ?['3. low'] ??
            '0.0';
        _averageValue1 = (double.parse(lowVal1) + double.parse(highVal1)) / 2;
        _averageValue2 = (double.parse(lowVal2) + double.parse(highVal2)) / 2;
        _sliderValue1 = _averageValue1;
        _sliderValue2 = _averageValue2;

        returnpage = !returnpage;
      } else {
        showErrorMsg("Please fill the input fields properly!");
      }
    });
  }

  DailyData? stockData;

  final quantity = TextEditingController();

  double _sliderValue1 = 0.0;
  double _sliderValue2 = 0.0; // Initial slider value (0.0 to 1.0)
  double _averageValue1 = 0.0;
  double _averageValue2 = 0.0; // The average value you want to display

  // final sellDate = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData(widget.symbol).then((data) {
      setState(() {
        stockData = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double displayW = MediaQuery.of(context).size.width;
    double displayH = MediaQuery.of(context).size.height;
    if (returnpage) {
      return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.green[200],
          title: const Text("Calculate Your Returns"),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: .014 * displayH),
                    Hero(
                      tag: 'hero-row',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                              child: TextField(
                                  onTap: () => _selectDate(context, true),
                                  controller: buyDateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Starting Date',
                                    fillColor: Colors.grey.shade200,
                                    filled: true,
                                  ))),
                          Expanded(
                              child: TextField(
                                  onTap: () => _selectDate(context, false),
                                  controller: sellDateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Ending Date',
                                    fillColor: Colors.grey.shade200,
                                    filled: true,
                                  ))),
                        ],
                      ),
                    ),
                    SizedBox(height: .014 * displayH),
                    Hero(
                      tag: 'hero-textfield',
                      child: TextField(
                          controller: quantity,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Quantity',
                            fillColor: Colors.grey.shade200,
                            filled: true,
                          )),
                    ),
                    SizedBox(height: .014 * displayH),
                    Hero(
                      tag: 'hero-button',
                      child: MyButton(
                          fnc: returns,
                          num: const Text('Show Returns'),
                          bgcolor: Colors.black87,
                          fgcolor: Colors.white,
                          wd: 0.90),
                    ),
                    Slider(
                      value: _sliderValue1,
                      min: double.parse(lowVal1),
                      max: double.parse(highVal1),
                      onChanged: (newValue) {
                        setState(() {
                          _sliderValue1 = newValue;
                        });
                      },
                    ),
                    Text('Value: ${_sliderValue1.toStringAsFixed(2)}'),
                    Slider(
                      value: _sliderValue2,
                      min: double.parse(lowVal2),
                      max: double.parse(highVal2),
                      onChanged: (newValue) {
                        setState(() {
                          _sliderValue2 = newValue;
                        });
                      },
                    ),
                    Text('Value: ${_sliderValue2.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.green[200],
          title: const Text("Calculate Your Returns"),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Hero(
                        tag: 'hero-row',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                                child: TextField(
                                    onTap: () => _selectDate(context, true),
                                    controller: buyDateController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Starting Date',
                                      fillColor: Colors.grey.shade200,
                                      filled: true,
                                    ))),
                            Expanded(
                                child: TextField(
                                    onTap: () => _selectDate(context, false),
                                    controller: sellDateController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Ending Date',
                                      fillColor: Colors.grey.shade200,
                                      filled: true,
                                    ))),
                          ],
                        ),
                      ),
                      SizedBox(height: .014 * displayH),
                      Hero(
                        tag: 'hero-textfield',
                        child: TextField(
                            controller: quantity,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Quantity',
                              fillColor: Colors.grey.shade200,
                              filled: true,
                            )),
                      ),
                      SizedBox(height: .014 * displayH),
                      Hero(
                        tag: 'hero-button',
                        child: MyButton(
                            fnc: returns,
                            num: const Text('Show Returns'),
                            bgcolor: Colors.black87,
                            fgcolor: Colors.white,
                            wd: 0.90),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
