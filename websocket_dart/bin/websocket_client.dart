import 'dart:convert';
import 'dart:io';

import 'package:websocket_dart/websocket_dart.dart' as websocket_dart;
import 'package:galaxeus_lib/galaxeus_lib.dart';

void main(List<String> arguments) {
  WebSocketClient ws = WebSocketClient("ws://0.0.0.0:8080/ws");

  ws.on(ws.event_name_update, (update) {
    print(update);
  });

  ws.connect(
    onDataConnection: (data) {
      print(data);
    },
  );

  stdin.listen((event) {
    String data = utf8.decode(event);
    ws.clientSend(data);
  });
}
