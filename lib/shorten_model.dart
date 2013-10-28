library shorten_model;

import "dart:convert";

class Shorten {
  
  final String key;
  final String longUrl;
  
  Shorten(this.key, this.longUrl);
  
  factory Shorten.fromJson(String str){
    final json = JSON.decoder(str);
    return new Shorten(json['key'], json["longUrl"]);
  }
  
  factory Shorten.fromMap(Map map) =>
    new Shorten(map['_id'], map["longUrl"]);
  
  String toString() => "{'key':$key,'longUrl':$longUrl}";
  
}