import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get_stonkd/pages/auth_page.dart';
import 'package:get_stonkd/pages/calci.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class Results {
  final String symbol;
  final String name;

  Results({
    required this.symbol,
    required this.name,
  });

  factory Results.fromJson(Map<String, dynamic> json) {
    return Results(
      symbol: json['1. symbol'],
      name: json['2. name'],
    );
  }
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;
  final searchController = TextEditingController();

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  Future<List<Results>> fetchResults(String search) async {
    if (search.isEmpty) {
      return [];
    }
    // Specify the URL
    var url = Uri.parse(
        'https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=' +
            search +
            '&apikey=27934ROJSB0SQMHI');

    // Make the GET request
    var response = await http.get(url);

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Decode the response body
      var data = jsonDecode(response.body);
      if (data['bestMatches'] != null && data['bestMatches'] is List) {
        final List<dynamic> bestMatchesJson = data['bestMatches'];
        return bestMatchesJson.map((json) => Results.fromJson(json)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double displayW = MediaQuery.of(context).size.width;
    double displayH = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: const Color.fromARGB(255, 255, 218, 185),
          title: const Text("Choose Your Stock"),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: signUserOut,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Stack(children: <Widget>[
          // Background image
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
            child: Column(children: [
              // const Text(
              //   'Welcome Back!',
              //   style: TextStyle(
              //     color: Colors.black87,
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const Text(
              //   'We\'re so excited to see you again!',
              //   style: TextStyle(
              //     color: Colors.black87,
              //     fontSize: 16,
              //   ),
              // ),
              SizedBox(height: .035 * displayH),
              TypeAheadField<Results>(
                suggestionsCallback: (search) => fetchResults(search),
                builder: (context, controller, focusNode) {
                  return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Search',
                        fillColor: Colors.grey.shade200,
                        filled: true,
                      ));
                },
                itemBuilder: (context, results) {
                  return ListTile(
                    title: Text(results.symbol),
                    subtitle: Text(results.name),
                  );
                },
                onSelected: (results) {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => Calci(symbol: results.symbol),
                    ),
                  );
                },
              ),
              SizedBox(height: .07 * displayH),

              // not a member? register now
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "logged in as : " + user.email!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(width: .0056 * displayW),
              ]),
            ]),
          ))
        ]));
  }
}
