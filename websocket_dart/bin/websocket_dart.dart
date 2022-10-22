// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:alfred/src/type_handlers/websocket_type_handler.dart';
import 'package:uuid/uuid.dart';

void main() async {
  int port = int.parse(Platform.environment["PORT"] ?? "8080");
  String host = Platform.environment["HOST"] ?? "0.0.0.0";
  final app = Alfred();
  app.all("/", (req, res) {
    return res.send({"@type": "ok"});
  });
  late List<WebSocketData> clients = [];
  app.get('/ws', (req, res) {
    return WebSocketSession(
      onOpen: (ws) {
        bool is_save_socket = clients.saveWebsocket(webSocket: ws);
        if (is_save_socket) {
          ws.sendJson({"@type": "message", "message": "Hai perkenalkan aku adalah robot"});
        } else {
          ws.sendJson({"@type": "message", "message": "Aku pergi ya dadah"});
          ws.close();
          return;
        }
      },
      onClose: (ws) {
        clients.deleteWebSocketByWebsocket(webSocket: ws);
      },
      onMessage: (ws, dynamic data) async {
        try {
          if (data is String) {
            Map body = json.decode(data);
            if (body["@type"] == "message") {
              late String message = "";
              if (body["message"] is String) {
                message = body["message"];
              }
              if (RegExp(r"/start", caseSensitive: false).hasMatch(message)) {
                ws.sendJson({
                  "@type": "message",
                  "message": "Hai saya robot buatan azkadev",
                });
                return;
              }
              ws.sendJson({"@type": "message", "message": "echo ${message}"});
              return;
            }
          }
          ws.sendJson({"@type": "message", "message": "Maaf pesan anda tidak support"});
        } catch (e) {
          ws.sendJson({"@type": "message", "message": "Error ${e}"});
        }
      },
    );
  });

  final server = await app.listen(port, host);

  print('Listening on ${server.port}');
}

extension WebSocketSendJson on WebSocket {
  void sendJson(Map data) {
    return send(json.encode(data));
  }
}

class WebSocketData {
  late String socket_id;
  late WebSocket webSocket;
  WebSocketData({
    required this.socket_id,
    required this.webSocket,
  });
}

extension WebSocketDatasExtensions on List<WebSocketData> {
  void broadCastAll(dynamic data) {
    for (var i = 0; i < length; i++) {
      WebSocketData webSocketData = this[i];
      webSocketData.webSocket.send(data);
    }
    return;
  }

  void broadCast({
    required dynamic data,
    bool isExceptMe = false,
    required WebSocket ws,
  }) {
    for (var i = 0; i < length; i++) {
      WebSocketData webSocketData = this[i];
      if (isExceptMe) {
        if (webSocketData.webSocket == ws) {
          continue;
        }
      }
      webSocketData.webSocket.send(data);
    }
    return;
  }

  bool saveWebsocket({required WebSocket webSocket}) {
    try {
      DateTime time_out = DateTime.now().add(Duration(seconds: 10));
      List<String> socket_ids = map((e) => e.socket_id).toList().cast<String>();
      late String socketId = Uuid().v4();
      while (true) {
        if (time_out.isBefore(DateTime.now())) {
          return false;
        }
        if (socket_ids.contains(socketId)) {
          socketId = Uuid().v4();
        } else {
          add(WebSocketData(socket_id: socketId, webSocket: webSocket));
          return true;
        }
      }
    } catch (E) {
      return false;
    }
  }

  bool deleteWebSocketById({
    required String socketId,
  }) {
    for (var i = 0; i < length; i++) {
      // ignore: non_constant_identifier_names
      WebSocketData webSocketData = this[i];
      if (webSocketData.socket_id == socketId) {
        webSocketData.webSocket.close();
        remove(i);
        return true;
      }
    }
    return false;
  }

  bool deleteWebSocketByWebsocket({
    required WebSocket webSocket,
  }) {
    for (var i = 0; i < length; i++) {
      // ignore: non_constant_identifier_names
      WebSocketData webSocketData = this[i];
      if (webSocketData.webSocket == webSocket) {
        webSocketData.webSocket.close();
        remove(i);
        return true;
      }
    }
    return false;
  }

  WebSocketData? getWebSocketByWebsocket({
    required WebSocket webSocket,
  }) {
    for (var i = 0; i < length; i++) {
      WebSocketData webSocketData = this[i];
      if (webSocketData.webSocket == webSocket) {
        return webSocketData;
      }
    }
    return null;
  }
}
