library shorten_server;

import 'dart:io';
import 'package:route/server.dart';
import 'package:pathos/path.dart' as path;
import 'package:shorten/shorten_db.dart';
import 'dart:async';

final KEY_URL = new UrlPattern(r"/(\w+)");
final OTHERS_URL = new UrlPattern(r"/(.)*");
final CACHE_MAX_AGE = 31536000; // Cache for 1 year
final WEB_DIR = path.absolute("web");

ShortenRepository _repository;
HttpServer _server;

class ShortenServer {
  
  static start(String host, int port, String mongoUri){
    // TODO close errors
    Future.wait([ShortenDB.connect(mongoUri), HttpServer.bind(host, port)])
          //.catchError(_serverFailed)
          .then(_onReady, onError: _serverFailed);
  }
  
}

_serverFailed(e){
  print("Server failed to start\n$e");
}

_onReady(results){
  _repository = results[0];
  _configureRoutes(results[1]); 
}

_configureRoutes(HttpServer server) {
  print("Server start on port ${server.port}");
  new Router(server)
    ..serve(KEY_URL, method : 'GET').listen(_serveKey)
    ..serve(OTHERS_URL, method: "GET").listen(_serveFile);
}

_serveKey(HttpRequest request){
  final key = request.uri.path.substring(1);
  _repository.findFromKey(key)
             .then((urlEntry) => _redirectTo(request.response, urlEntry.longUrl),
                onError: (e) =>  _send404(request.response)   
              );
  
}

_serveFile(HttpRequest request) {
  final uriPath = request.uri.path;
  final filename = (uriPath.endsWith("/")) ? "${uriPath}index.html" : uriPath;
  final filepath = "$WEB_DIR$filename";
  final file = new File(filepath);
  file.exists().then((isExist) {
    if(isExist){
      // TODO header ?
      // TODO deal stream errors
      file.openRead().pipe(request.response);
    } else {
      _send404(request.response);
    }
  });

}



_redirectTo(HttpResponse response, String url) =>
  response..statusCode = HttpStatus.MOVED_PERMANENTLY
          ..headers.set(HttpHeaders.LOCATION, url)
          ..headers.set(HttpHeaders.CACHE_CONTROL, "public,max-age=$CACHE_MAX_AGE")
          ..close();

_send404(HttpResponse response){
  // TODO special page
  response..statusCode = HttpStatus.NOT_FOUND
          ..close();  
}