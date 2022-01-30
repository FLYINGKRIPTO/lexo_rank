import 'package:flutter/material.dart';
import 'package:lexo_rank/lexo_rank.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexo Rank Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Lexo Rank '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LexoRank initialLexoRank = LexoRank.middle();
  LexoRank? prevLexoRank;
  LexoRank? nextLexoRank;
  LexoRank? middleLexoRank;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  LexoRank rank = LexoRank.middle();
                  setState(() {
                    initialLexoRank = rank;
                  });
                },
                child: const Text("Generate middle"),
              ),
              Text(initialLexoRank.value),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    prevLexoRank = initialLexoRank.genPrev();
                  });
                },
                child: const Text("Generate previous"),
              ),
              Text(prevLexoRank?.value ?? ""),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    nextLexoRank = initialLexoRank.genNext();
                  });
                },
                child: const Text("Generate next"),
              ),
              Text(nextLexoRank?.value ?? ""),
            ],
          ),
          prevLexoRank != null && nextLexoRank != null
              ? Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          middleLexoRank = prevLexoRank!.between(nextLexoRank!);
                        });
                      },
                      child: const Text("Generate middle"),
                    ),
                    Text(middleLexoRank?.value ?? ""),
                  ],
                )
              : Container(),
        ],
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
