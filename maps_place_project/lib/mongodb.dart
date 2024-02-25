import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'api.dart';

class MongoDatabase {
//Kayıt ol kısmında kullanıcı ekleme
  static UsersInsert(
      String url, String tableName, String eposta, String sifre) async {
    var db = await Db.create(url);
    await db.open();
    inspect(db);
    var status = db.serverStatus();
    print(status);
    var collection = db.collection(tableName);
    var deger = await collection.insertMany([
      {"eposta": "$eposta", "şifre": "$sifre", "FavoriMekanlar": []}
    ]);
    print(await collection.find().toList());
  }
//kayıt ol kısmında kullanıcının zaten veritabanında hesabı varmı kontrolu
  static Future<bool> SingUpUsersControl(
      String url, String tableName, String email) async {
    var db = await Db.create(url);
    await db.open();
    inspect(db);
    var status = db.serverStatus();

    var collection = db.collection(tableName);
    var deger = await collection.findOne({"eposta": email});

    // Eğer deger null değilse ve "isim" alanı email değerine eşitse true döndür
    if (deger != null) {
   return true;
    } else {
      return false;
    }
    // return deger != null && deger["isim"] == email;
  }

 //Kullanıcı giris yaparken veritabanında hesap varmı Kontrolu
  static Future<bool> LoginUsersControl(
      String url, String tableName, String email, String sifre) async {
    var db = await Db.create(url);
    await db.open();
    inspect(db);
    var status = db.serverStatus();

    var collection = db.collection(tableName);
    var deger = await collection.findOne({"eposta": email, "şifre": sifre});

    // Eğer deger null değilse ve "isim" alanı email değerine eşitse true döndür
    if (deger != null) {
      return true;
    } else {
      return false;
    }
    // return deger != null && deger["isim"] == email;
  }
 
     //Seçilen mekanı veritabanında favori mekanlara ekleme kodu
  static Future<void> InsertfavoritePlace(
      String url, String tableName, String eposta, Place place) async {
    var db = await Db.create(url);
    await db.open();
    inspect(db);
    var status = db.serverStatus();

    var collection = db.collection(tableName);

   
    final query = where.eq(
      'eposta',
      eposta,
    );

    final update = {
      '\$push': {"FavoriMekanlar": place.toMap()},
    };
  

    await collection.update(query, update);

    await db.close();
  }

  //FavorimEkanları veritabanından çekme kodu

  static Future<List<Object>> SelectFavoritePlace(
      String url, String tableName, String eposta, String sifre) async {
    try {
      var db = await Db.create(url);
      await db.open();
      
      var collection = db.collection(tableName);
      
      final query = where.eq('eposta', eposta);
      final result = await collection.findOne(query);
      

      if (result != null && result['FavoriMekanlar'] != null) {
        List<Map<String, dynamic>> favoriMekanlarMapList =
            List<Map<String, dynamic>>.from(result['FavoriMekanlar']);
        
        debugPrint(favoriMekanlarMapList.toString());
        for (var element in favoriMekanlarMapList) {
          debugPrint(element.toString());
        }
       

        return favoriMekanlarMapList;
      } else {
        debugPrint("Favori Mekanlar bulunamadı.");
        return [];
      }
    } catch (error) {

      return []; // Hata durumunda boş bir liste 
    }
  }

  
}
