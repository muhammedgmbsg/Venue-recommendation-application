import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive_animation/SearchScreen.dart';
import 'package:rive_animation/screens/onboding/onboding_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'FavoritePlacesScreen.dart';
import 'api.dart';
import 'mongodb.dart';

//ignore: must_be_immutable
class ResultsScreen extends StatelessWidget {
  final String eposta;
  final String sifre;
  final List<Place> places;

  ResultsScreen(this.places, this.eposta, this.sifre);

  List<Place> favoritePlaces = [];

  @override
  Widget build(BuildContext context) {
    // Mekanları puanlarına göre büyükten küçüğe sırala
    places.sort((a, b) => b.rating.compareTo(a.rating));

    return ScreenUtilInit(
      designSize: Size(411.4, 820.6),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => WillPopScope(
        onWillPop: () async {
          // Geri tuşu kullanımını kontrol etmek istediğiniz koşulları burada belirtin.
          // Eğer geri tuşunu devre dışı bırakmak istiyorsanız `false` döndürün.
          return false;
        },
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 236, 235, 235),
          bottomNavigationBar: CurvedNavigationBar(
            height: 55,
            color: Color.fromARGB(248, 236, 121, 136),
            backgroundColor: Color.fromARGB(255, 236, 235, 235),
            animationDuration: const Duration(milliseconds: 300),
            index: 1,
            items: const [
              Icon(
                Icons.search,
                color: Colors.white,
              ),
              Icon(
                Icons.favorite_border_outlined,
                color: Colors.white,
                size: 23,
              ),
              Icon(Icons.exit_to_app_outlined, color: Colors.white),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          SearchScreen(eposta: eposta, sifre: sifre)));
                  break;
                case 1:
                  // Handle messenger icon tap
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          FavoritePlacesScreen(eposta, sifre)));
                  print('Messenger icon tapped');
                  break;
                case 2:
                  _showExitDialog(context);
              }
            },
          ),
          appBar: AppBar(
            title: const Text('Arama Sonuçları'),
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFF77D8E),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                // Mekan numarasını hesapla (1'den başlayarak)
                int placeNumber = index + 1;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 231, 231, 231),
                    ),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$placeNumber. ${_truncateString(places[index].name, places[index].name.length > 30 ? 27 : places[index].name.length > 27 ? 30 : 33)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '⭐ ${places[index].rating.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        _showDetailsDialog(context, places[index]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _truncateString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength) + '...';
  }

  void _showDetailsDialog(BuildContext context, Place place) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScreenUtilInit(
          designSize: Size(411.4, 820.6),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      place.name,
                      style: const TextStyle(
                        color: Color(0xFFF77D8E),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: place.address.length < 70
                                    ? 22
                                    : place.address.length < 100
                                        ? 41
                                        : 60),
                            child: Text(
                              'Adres: ',
                              style: GoogleFonts.varela(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '${place.address}',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Text('Telefon: ',
                            style: GoogleFonts.varela(
                                fontWeight: FontWeight.bold)),
                        Text(
                          '${place.phone}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          'Websitesi: ',
                          style:
                              GoogleFonts.varela(fontWeight: FontWeight.bold),
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              if (place.website != 'Bulunamadı') {
                                // ignore: deprecated_member_use
                                await launch(place.website);
                              }
                            },
                            child: Text(
                              place.website != 'Bulunamadı'
                                  ? 'Ziyaret et'
                                  : 'Bulunamadı',
                              style: TextStyle(
                                color: place.website != 'Bulunamadı'
                                    ? Colors.blue
                                    : Colors.black,
                                decoration: place.website != 'Bulunamadı'
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Text(
                          'Çalışma Saatleri',
                          style:
                              GoogleFonts.varela(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildWorkingHours(place.weekday_text),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      InsertFavoriPlace(eposta, place);
                      favoritePlaces.add(place);
                      Navigator.of(context).pop();
                      debugPrint('$favoritePlaces'.toString());

                      // Bir mekanı favorilere ekledikten sonra FavoritePlacesScreen sayfasına yönlendir
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width > 400
                              ? 200.w
                              : 170.w),
                      child: Row(
                        children: [
                          Text(
                            'Favorilere Ekle',
                            style: TextStyle(color: Color(0xFFF77D8E)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String convertToTurkishStatus(String status) {
    status = status.toLowerCase().replaceAll('hours', 'saat');
    status = status.replaceAll('open', 'Açık:');
    status = status.replaceAll('closed', 'Kapalı');

    return status;
  }

  List<Widget> _buildWorkingHours(String workingHoursString) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final turkishDays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    workingHoursString = workingHoursString
        .replaceAll('[', '') // '[' ve ']' karakterlerini kaldır
        .replaceAll(']', '');

    final workingHoursList = workingHoursString.split(', ');

    if (workingHoursList.isEmpty) {
      return [const Text('Çalışma saatleri bulunamadı.')];
    }

    return workingHoursList.map((workingHour) {
      final components = workingHour.split(': ');

      if (components.length >= 2) {
        final dayIndex = days.indexOf(components[0]);
        final hours = convertToTurkishStatus(components[1]);
        return Text('${turkishDays[dayIndex]}: $hours');
      } else {
        return const Text('Çalışma Saati Bulunamadı');
      }
    }).toList();
  }

  Future<void> InsertFavoriPlace(String epostadegeri, Place place) async {
    await MongoDatabase.InsertfavoritePlace(
      "mongodb+srv://user123:user4455@cluster0.40yopgu.mongodb.net/PlaceMaps?retryWrites=true&w=majority",
      "Place",
      epostadegeri.toString(),
      place,
    );
  }

  Future<void> _showExitDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Çıkış Yapmak İstiyor Musunuz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Kapatma işlemi
              },
              child: Text(
                'Hayır',
                style: TextStyle(
                  color: Color.fromARGB(248, 236, 121, 136),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Kapatma işlemi
                // Burada çıkış işlemleri gerçekleştirilebilir
                // Örneğin: exit(0);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const OnboardingScreen()));
              },
              child: Text(
                'Evet',
                style: TextStyle(
                  color: Color.fromARGB(248, 236, 121, 136),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
