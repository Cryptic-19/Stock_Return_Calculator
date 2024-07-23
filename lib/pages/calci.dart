import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_stonkd/components/my_button.dart';
import 'package:get_stonkd/pages/auth_page.dart';
import 'package:get_stonkd/pages/history.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Calci extends StatefulWidget {
  final String symbol;
  const Calci({super.key, required this.symbol});

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
      return '0.0';
    }
  }

  String? getLowValueForDate(String date) {
    if (timeSeries.containsKey(date)) {
      return timeSeries[date]?['3. low'];
    } else {
      return '0.0';
    }
  }
}

Future<DailyData> fetchData(String stock) async {
  // Specify the URL

  final String apiKey = dotenv.env['API_KEY'] ?? "No api key";
  var url = Uri.parse(
      'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&outputsize=full&symbol=$stock&apikey=$apiKey');

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
  final user = FirebaseAuth.instance.currentUser!;

  DateTime? buyDate;
  DateTime? sellDate;

  final TextEditingController buyDateController = TextEditingController();
  final TextEditingController sellDateController = TextEditingController();

  bool returnpage = false;
  String highVal1 = '0.0';
  String lowVal1 = '0.0';
  String highVal2 = '0.0';
  String lowVal2 = '0.0';
  String text = '';

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

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  double calculateFontSize(int length) {
    if (length <= 9) {
      return 0.06;
    } else if (length <= 15) {
      return 0.04;
    } else if (length <= 21) {
      return 0.02;
    } else {
      return 0.01;
    }
  }

  Future storeReturn(String email) async {
    await FirebaseFirestore.instance.collection('user:$email').add({
      'Stock Name': widget.symbol,
      'Starting Date': buyDateController.text,
      'Ending Date': sellDateController.text,
      'Quantity': quantity.text,
      'Returns': text[0] == '+'
          ? 'Profit: $text'
          : (text[0] == '-' ? 'Loss: $text' : 'No Profit/Loss : $text'),
      'time': Timestamp.now()
    });
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
        _averageValue1 = double.parse(
            ((double.parse(lowVal1) + double.parse(highVal1)) / 2)
                .toStringAsFixed(2));
        _averageValue2 = double.parse(
            ((double.parse(lowVal2) + double.parse(highVal2)) / 2)
                .toStringAsFixed(2));
        _sliderValue1 = _averageValue1;
        _sliderValue2 = _averageValue2;

        returnpage = !returnpage;
      } else {
        showErrorMsg("Please fill the input fields properly!");
      }
    });
  }

  DailyData? stockData;

  final quantity = TextEditingController(text: '1');

  double _sliderValue1 = 0.0;
  double _sliderValue2 = 0.0;
  double _averageValue1 = 0.0;
  double _averageValue2 = 0.0;

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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
            backgroundBlendMode: BlendMode.darken,
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            foregroundColor: Colors.black,
            backgroundColor:
                const Color.fromARGB(255, 255, 218, 185).withOpacity(.85),
            title: Text(widget.symbol),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const History()),
                ),
                icon: const Icon(Icons.history),
              ),
              IconButton(
                onPressed: signUserOut,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          backgroundBlendMode: BlendMode.lighten,
        ),
        child: FloatingActionButton(
          splashColor: const Color.fromARGB(255, 185, 207, 255),
          backgroundColor:
              const Color.fromARGB(255, 255, 218, 185).withOpacity(0.75),
          shape: const StadiumBorder(),
          onPressed: () {
            if (returnpage) {
              storeReturn(user.email!);
              showErrorMsg('Data saved successfully!');
            } else {
              showErrorMsg('Nothing to save yet!');
            }
          },
          child: const Icon(Icons.save_as_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: displayH * .95,
            child: SafeArea(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/background.jpeg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: .014 * displayH),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: returnpage ? .014 * displayH : (0.56 * displayH) / 2,
                    left: 0.025 * displayW,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                          0.025 * displayW, 0, 0.025 * displayW, 0),
                      width: 0.95 * displayW,
                      height: 0.30 * displayH,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        backgroundBlendMode: BlendMode.lighten,
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: .014 * displayH),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                  child: TextField(
                                      onTap: () => _selectDate(context, true),
                                      controller: buyDateController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
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
                                        border: const OutlineInputBorder(),
                                        labelText: 'Ending Date',
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ))),
                            ],
                          ),
                          SizedBox(height: .014 * displayH),
                          TextField(
                              controller: quantity,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Quantity',
                                fillColor: Colors.grey.shade200,
                                filled: true,
                              )),
                          SizedBox(height: .014 * displayH),
                          MyButton(
                              fnc: returns,
                              num: const Text('Show Returns'),
                              bgcolor: Colors.black87,
                              fgcolor: Colors.white,
                              wd: 0.90),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: .014 * displayH),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: returnpage ? 0.282 * displayH : -(0.32 * displayH),
                    left: 0.05 * displayW,
                    child: Container(
                      width: 0.9 * displayW,
                      height: 0.34 * displayH,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        backgroundBlendMode: BlendMode.lighten,
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: .004 * displayH),
                          Text(
                            'Buying Price',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 0.03 * displayH,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Slider(
                            value: _sliderValue1,
                            min: double.parse(
                                double.parse(lowVal1).toStringAsFixed(2)),
                            max: double.parse(
                                double.parse(highVal1).toStringAsFixed(2)),
                            divisions: ((double.parse(highVal1) -
                                                double.parse(lowVal1)) /
                                            0.01)
                                        .round() !=
                                    0
                                ? ((double.parse(highVal1) -
                                            double.parse(lowVal1)) /
                                        0.01)
                                    .round()
                                : 1,
                            onChanged: (newValue) {
                              setState(() {
                                _sliderValue1 = newValue;
                              });
                            },
                          ),
                          Text(
                            _sliderValue1.toStringAsFixed(2),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 0.03 * displayH,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(
                            color: Colors.black,
                            thickness: 1, // Thickness of the line
                            indent: 20, // Left indent
                            endIndent: 20, // Right indent
                          ),
                          Text(
                            'Selling Price',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 0.03 * displayH,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Slider(
                            value: _sliderValue2,
                            min: double.parse(
                                double.parse(lowVal2).toStringAsFixed(2)),
                            max: double.parse(
                                double.parse(highVal2).toStringAsFixed(2)),
                            divisions: ((double.parse(highVal2) -
                                                double.parse(lowVal2)) /
                                            0.01)
                                        .round() !=
                                    0
                                ? ((double.parse(highVal2) -
                                            double.parse(lowVal2)) /
                                        0.01)
                                    .round()
                                : 1,
                            onChanged: (newValue) {
                              setState(() {
                                _sliderValue2 = newValue;
                              });
                            },
                          ),
                          Text(
                            _sliderValue2.toStringAsFixed(2),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 0.03 * displayH,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: .028 * displayH),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom:
                        returnpage ? 0.09 * displayH : (-0.62 * displayH) / 2,
                    left: 0.15 * displayW,
                    child: Container(
                      width: 0.7 * displayW,
                      height: 0.16 * displayH,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        color: _sliderValue2.toStringAsFixed(2) ==
                                _sliderValue1.toStringAsFixed(2)
                            ? const Color.fromARGB(255, 253, 237, 95)
                                .withOpacity(0.5)
                            : (_sliderValue2 > _sliderValue1
                                ? const Color.fromARGB(255, 201, 255, 185)
                                    .withOpacity(0.5)
                                : const Color.fromARGB(255, 244, 118, 118)
                                    .withOpacity(0.7)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _sliderValue2.toStringAsFixed(2) ==
                                    _sliderValue1.toStringAsFixed(2)
                                ? 'Break Even :o'
                                : (_sliderValue2 > _sliderValue1
                                    ? 'Profit :)'
                                    : 'Loss :('),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 0.03 * displayH,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: .014 * displayH),
                          Text(
                            text = (_sliderValue2.toStringAsFixed(2) ==
                                    _sliderValue1.toStringAsFixed(2)
                                ? '\$ 0.00'
                                : (_sliderValue2 > _sliderValue1
                                    ? '+\$ ${((double.parse(_sliderValue2.toStringAsFixed(2)) - double.parse(_sliderValue1.toStringAsFixed(2))) * double.parse(quantity.text)).toStringAsFixed(2)}'
                                    : '-\$ ${((double.parse(_sliderValue1.toStringAsFixed(2)) - double.parse(_sliderValue2.toStringAsFixed(2))) * double.parse(quantity.text)).toStringAsFixed(2)}')),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize:
                                  calculateFontSize(text.length) * displayH,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
