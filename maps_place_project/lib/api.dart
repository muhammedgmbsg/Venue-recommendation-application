import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<List<Place>> searchPlaces(
    String city,
    String district,
    String keyword,
  ) async {
    String apiKey =
        'AIzaSyAxMbv8Ktrj_etOMNIL5Jk6N8VQus52JqE'; // Replace with your actual API key
    String searchUrl =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$keyword+$city+$district&key=$apiKey';

    final searchResponse = await http.get(Uri.parse(searchUrl));
    if (searchResponse.statusCode == 200) {
      final searchData = json.decode(searchResponse.body);
      if (searchData['status'] == 'OK') {
        List<Place> places =
            List<Place>.from(searchData['results'].map((place) {
          return Place(
            name: place['name'],
            address: place['formatted_address'],
            rating: place['rating']?.toDouble() ?? 0.0,
            placeId: place['place_id'],
            phone: '',
            website: '',
            weekday_text: null,
          );
        }));

        for (Place place in places) {
          String placeId = place.placeId;
          String detailsUrl =
              'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$apiKey';
          final detailsResponse = await http.get(Uri.parse(detailsUrl));
          if (detailsResponse.statusCode == 200) {
            final detailsData = json.decode(detailsResponse.body);
            if (detailsData['status'] == 'OK') {
              place.phone =
                  detailsData['result']['formatted_phone_number']?.toString() ??
                      'Bulunamadı';
              place.website =
                  detailsData['result']['website']?.toString() ?? 'Bulunamadı';
              if (detailsData['result']['opening_hours'] != null &&
                  detailsData['result']['opening_hours']['weekday_text'] !=
                      null) {
                place.weekday_text = detailsData['result']['opening_hours']
                        ['weekday_text']
                    .toString();
              } else {
                place.weekday_text = 'Bulunamadı';
              }
            }
          }
        }

        return places;
      } else {
        throw Exception(searchData['error_message']);
      }
    } else {
      throw Exception(
          'Arama sırasında hata oluştu: ${searchResponse.reasonPhrase}');
    }
  }
}

class Place {
  final String name;
  final String address;
  final double rating;
  final String placeId;
  String phone;
  String website;

  var weekday_text;

  Place({
    required this.name,
    required this.address,
    required this.rating,
    required this.placeId,
    required this.phone,
    required this.website,
    required this.weekday_text,
  });

  get formatted_phone_number => null;

  //toMap() {}

  static fromMap(Map<String, dynamic> placeMap) {}

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'address': address,
      'phone': phone,
      'website': website,
      'weekday_text': weekday_text,
    };
  }

  /* factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'] ?? '',
      rating: json['rating'] != null ? json['rating'].toDouble() : 0.0,
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      weekday_text: json['weekday_text'] ?? '',
      height: null, placeId: '', widht: null, photos: [], photoReference: null,
        
        
    );
  }*/
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'] ?? '',
      rating: json['rating'] != null ? json['rating'].toDouble() : 0.0,
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      weekday_text: json['weekday_text'] != null
          ? List<String>.from(json['weekday_text'])
          : "",
      placeId: json['placeId'] != null ? json['placeId'].toString() : " ",
    );
  }
}
