import 'dart:io';

import 'package:galaxeus_lib/galaxeus_lib.dart';

void main() {
  var result = jsonToDart({
    "@type": "message",
    "is_outgoing": false,
    "message": "",
  }, className: "Message");
  File("/home/hexaminate/azkadev/chatbot_flutter/chatbot_scheme/lib/chatbot_scheme.dart").writeAsString(result);
}
