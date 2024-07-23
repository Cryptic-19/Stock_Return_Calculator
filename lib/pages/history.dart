import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_stonkd/pages/auth_page.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final user = FirebaseAuth.instance.currentUser!;

  Future deleteReturn(String email, String docID) {
    return FirebaseFirestore.instance
        .collection('user:$email')
        .doc(docID)
        .delete();
  }

  Stream<QuerySnapshot> getHistory(String email) {
    final historyStream = FirebaseFirestore.instance
        .collection('user:$email')
        .orderBy('time', descending: true)
        .snapshots();
    return historyStream;
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
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
            title: const Text('History'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: signUserOut,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: getHistory(user.email!),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List calcList = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: calcList.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = calcList[index];
                    String docID = document.id;

                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String stock = data['Stock Name'];
                    String returns = data['Returns'];
                    String buyDate = data['Starting Date'];
                    String sellDate = data['Ending Date'];
                    String quantity = data['Quantity'];

                    return Padding(
                      padding: EdgeInsets.fromLTRB(0.025 * displayW,
                          0.009 * displayH, 0.025 * displayW, 0.009 * displayH),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                              color: returns[0] == 'P'
                                  ? const Color.fromARGB(255, 201, 255, 185)
                                      .withOpacity(0.5)
                                  : (returns[0] == 'N'
                                      ? const Color.fromARGB(255, 253, 237, 95)
                                          .withOpacity(0.5)
                                      : const Color.fromARGB(255, 244, 118, 118)
                                          .withOpacity(0.7)),
                            ),
                            child: ListTile(
                              title: Text(stock),
                              trailing: IconButton(
                                  onPressed: () =>
                                      deleteReturn(user.email!, docID),
                                  icon: const Icon(Icons.delete)),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.transparent,
                                      contentPadding: EdgeInsets.zero,
                                      content: Stack(
                                        clipBehavior: Clip.none,
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.fromLTRB(
                                                0.04 * displayW,
                                                0.02 * displayH,
                                                0.04 * displayW,
                                                0.02 * displayH),
                                            decoration: BoxDecoration(
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 10,
                                                  offset: Offset(0, 5),
                                                ),
                                              ],
                                              backgroundBlendMode:
                                                  BlendMode.lighten,
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Colors.blue,
                                                  Colors.purple
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Stock: $stock',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 0.03 * displayH,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                    height: 0.007 * displayH),
                                                Text(
                                                  'Buying Date: $buyDate',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 0.027 * displayH,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: 0.004 * displayH),
                                                Text(
                                                  'Selling Date: $sellDate',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 0.027 * displayH,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: 0.004 * displayH),
                                                Text(
                                                  'Quantity: $quantity',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 0.027 * displayH,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: 0.004 * displayH),
                                                Text(
                                                  returns,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 0.027 * displayH,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            right: -5,
                                            top: -5,
                                            child: IconButton(
                                              icon: const Icon(Icons.close,
                                                  color: Colors.white),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Text('loading...');
              }
            },
          ),
        ],
      ),
    );
  }
}
