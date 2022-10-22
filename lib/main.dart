import 'dart:convert';

import 'package:chatbot_scheme/chatbot_scheme.dart';
import 'package:flutter/material.dart';
import "package:galaxeus_lib/galaxeus_lib.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebSocketClient ws;
  TextEditingController textEditingController = TextEditingController();
  late List<Message> messages = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    task();
  }

  void task() async {
    setState(() {
      ws = WebSocketClient("ws://0.0.0.0:8080/ws");
    });
    ws.on(ws.event_name_update, (update) {
      try {
        if (update is String) {
          Map data = json.decode(update);
          if (data.isNotEmpty) {
            if (data["@type"] == "message") {
              setState(() {
                messages.add(Message(data));
              });
            }
          }
        } else {
          print(update);
        }
      } catch (e) {
        print(e);
      }
    });

    ws.connect(
      onDataConnection: (data) {
        print(data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: Column(
            children: messages
                .map((Message message) {
                  late AlignmentGeometry align_message = Alignment.centerLeft;
                  if (message.is_outgoing == true) {
                    align_message = Alignment.centerRight;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Align(
                      alignment: align_message,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 0,
                          minWidth: 0,
                          maxWidth: MediaQuery.of(context).size.width / 2,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
                            BoxShadow(
                              color: Colors.black87,
                              blurRadius: 0.2,
                              spreadRadius: 0.2,
                            )
                          ]),
                          padding: const EdgeInsets.all(10),
                          child: Text(message.message ?? "Pesan tidak support"),
                        ),
                      ),
                    ),
                  );
                })
                .toList()
                .cast<Widget>(),
          ),
        ),
      ),
      bottomNavigationBar: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 50,
          maxHeight: 70,
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextFormField(
                    controller: textEditingController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(5.0),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      floatingLabelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black87,
                        blurRadius: 0.2,
                        spreadRadius: 0.2,
                      )
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      if (textEditingController.text.isEmpty) {
                        return;
                      }
                      Message message = Message({
                        "@type": "message",
                        "is_outgoing": true,
                        "message": textEditingController.text,
                      });
                      setState(() {
                        messages.add(message);
                        ws.clientSendJson(message.toJson());
                        textEditingController.clear();
                      });
                    },
                    child: const Icon(Icons.send),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
