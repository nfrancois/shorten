library shorten_db;

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shorten/shorten_model.dart';
import 'dart:async';

class ShortenDB {
  
  final Db _db;
  ShortenDB(String uri) : _db = new Db( uri);
  
  static Future<ShortenRepository> connect(String uri) =>
    new _ShortenDB(uri)._connect();    
  
}

class _ShortenDB {

  final Db _db;
  _ShortenDB(String uri) : _db = new Db( uri);
  
  Future<ShortenRepository> _connect(){
    final completer = new Completer<ShortenRepository>();
    _db.open().then((bool isConnect){
      final collection = _db.collection(ShortenRepository.COLLECTION_NAME);
      completer.complete(new ShortenRepository(collection));
    }, onError: completer.completeError);
    return completer.future;
  }
  
}

class ShortenRepository {
  
  static final String COLLECTION_NAME = "shorten";
  final DbCollection collection;
  
  ShortenRepository(this.collection);
  
  Future<Shorten> findFromKey(String key){
    final completer = new Completer<Shorten>(); 
    collection.findOne(where.eq("_id", key)).then((result){
      if(result == null){
        completer.completeError("Not Found for key=$key");
      } else {
        completer.complete(new Shorten.fromMap(result));
      }
    });
    return completer.future;
  }
  
}