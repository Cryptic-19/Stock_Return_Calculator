import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get_stonkd/pages/auth_page.dart';
import 'package:get_stonkd/pages/calci.dart';
import 'package:get_stonkd/pages/history.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

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
  final String? apikey = dotenv.env['API_KEY'] ?? "No api key";

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
    var url = Uri.parse(
        'https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=$search&apikey=$apikey');

    var response = await http.get(url);

    if (response.statusCode == 200) {
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
              title: const Text("Choose Your Stock"),
              centerTitle: true,
              automaticallyImplyLeading: false,
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
        body: Stack(children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
              child: SingleChildScrollView(
            child: Column(children: [
              SizedBox(height: .035 * displayH),
              TypeAheadField<Results>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Search',
                    fillColor: Colors.grey.shade200,
                    filled: true,
                  ),
                ),
                suggestionsCallback: (search) async => fetchResults(search),
                suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                  color: Color.fromARGB(0, 255, 3, 3),
                ),
                itemBuilder: (context, Results results) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0.025 * displayW,
                        0.005 * displayH, 0.025 * displayW, 0.005 * displayH),
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(
                          decoration: const BoxDecoration(
                            backgroundBlendMode: BlendMode.lighten,
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            tileColor: const Color.fromARGB(255, 255, 218, 185)
                                .withOpacity(1.0),
                            title: Text(results.symbol),
                            subtitle: Text(results.name),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onSuggestionSelected: (Results results) {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => Calci(symbol: results.symbol),
                    ),
                  );
                },
                noItemsFoundBuilder: (context) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0.025 * displayW,
                        0.009 * displayH, 0.025 * displayW, 0.009 * displayH),
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(
                          decoration: const BoxDecoration(
                            backgroundBlendMode: BlendMode.lighten,
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            tileColor: const Color.fromARGB(255, 255, 218, 185)
                                .withOpacity(1.0),
                            title: const Text('No results found'),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: .07 * displayH),

              // not a member? register now
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "logged in as : ${user.email!}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(width: .0056 * displayW),
              ]),
            ]),
          ))
        ]));
  }
}
