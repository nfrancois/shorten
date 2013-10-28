// TODO move to lib
library shortener_server;

import 'dart:io';
import 'package:shorten/shorten_server.dart';

main(){
  final env = Platform.environment;
  final host = '0.0.0.0';
  final port = env.containsKey('PORT') ? int.parse(env['PORT']) : 7000;
  final mongoUri = env['SHORTEN_MONGO_URI'];
  
  ShortenServer.start(host, port, mongoUri);
}

