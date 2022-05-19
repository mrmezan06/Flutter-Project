import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran/coverter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late List<Result> result;
  Future<List<Result>> fetchJson() async {
    var response = await http.get(
      Uri.parse(
          "https://quranenc.com/api/v1/translation/sura/bengali_zakaria/2/"),
    );
    //debugPrint(response.statusCode.toString());
    // debugPrint(response.body);
    //return response.body;
    Sura sura = Sura.fromJson(jsonDecode(response.body));
   // debugPrint(sura.result[0].arabicText);

    return sura.result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF294034),
      child: SafeArea(
          child: Column(
        children: [
          FutureBuilder(
            future: fetchJson(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                //return Text(snapshot.data[0]['title']);
                //debugPrint(snapshot.data.length.toString());
                return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return card(
                            snapshot.data[index].aya,
                            snapshot.data[index].arabicText,
                            snapshot.data[index].translation);
                      }),
                );
              }else
              if (snapshot.hasError) {
                return const Text(
                  'Something Went Wrong!',
                  style: TextStyle(color: Colors.white),
                );
              }
              else if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              else{
                return const Text(
                  'Something Went Wrong!',
                  style: TextStyle(color: Colors.white),
                );
              }
            },
          ),
        ],
      )),
    );
  }
}


Widget card(String ayat, String arabic, String translate) {
  return Card(
    color: const Color(0xFF092918),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                child: Text(
                  ayat,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )),
            const Padding(
                padding: EdgeInsets.only(right: 5.0, top: 5.0),
                child: Text(
                  '...',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ))
          ],
        ),
        Text(arabic, style: const TextStyle(color: Colors.white)),
        Text(
          translate,
          style: const TextStyle(color: Colors.white),
        )
      ],
    ),
  );
}
