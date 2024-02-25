import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:rive/rive.dart';

import 'mongodb.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> with WidgetsBindingObserver {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isShowLoading = false;
  bool isShowConfetti = false;

  late SMITrigger check;
  late SMITrigger error;
  late SMITrigger reset;

  late SMITrigger confetti;

  StateMachineController getRiveController(Artboard artboard) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, "State Machine 1");
    artboard.addController(controller!);
    return controller;
  }

  String generateRandomCode() {
    Random random = Random();
    int min = 100000; // Minimum 6 basamaklı rakam
    int max = 999999; // Maximum 6 basamaklı rakam
    int randomNumber = min + random.nextInt(max - min);
    return randomNumber.toString();
  }

  Future<void> signUp(BuildContext context) async {
    setState(() {
      isShowLoading = true;
      isShowConfetti = true;
    });
    bool epostaKonrtol = await DbMailControl(eposta!);

    if (epostaKonrtol == true) {
      debugPrint("epostakontrol true");
    } else if (epostaKonrtol == false) {
      debugPrint("epostakontrol false");
    } else {
      debugPrint("epostakontrol belirsiz");
    }

    Future.delayed(Duration(seconds: 1), () {
      if (_formKey.currentState!.validate() &&
          epostaKonrtol == false &&
          passwordController.text.isNotEmpty) {
        // başarıyı göster
        check.fire();
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isShowLoading = false;
          });
          if (passwordController.text.isNotEmpty && epostaKonrtol == false) {
            debugPrint("${eposta.toString()}");
            debugPrint("${epostaKonrtol.toString()} + dsfdsg");
            confetti.fire();
            onaykod = generateRandomCode();
            sendEmail();
            showVerificationDialog(context); // Onay kodu dialogu
          }
        });
      } else {
        error.fire();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Girdiğiniz bilgiler yanlış veya zaten bir hesap oluşturulmuş !'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: const Color(0xFFF77D8E),
          behavior: SnackBarBehavior.floating,
        ));
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isShowLoading = false;
          });
        });
      }
    });
  }

  TextEditingController passwordController = TextEditingController(); // Ekledik
  TextEditingController CodeController = TextEditingController();
  TextEditingController epostaController = TextEditingController();

  String? sifre1;
  String? eposta;
  String? onaykod;
  String? inputonaykod;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(411.4, 820.6),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => Scaffold(
              appBar: AppBar(
                title: Text('Kayıt Ekranı'),
                backgroundColor: const Color(0xFFF77D8E),
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 45.w, vertical: 60.h),
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 30.h,
                            ),
                            const Text(
                              "Bilgileri eksiksiz girin",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 253, 128, 144),
                              ),
                            ),
                            SizedBox(
                              height: 30.h,
                            ),
                            const Text(
                              "E-posta Adresinizi Girin",
                              style: TextStyle(color: Colors.black54),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 16),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "E-posta alanı boş bırakılamaz.";
                                  } else if (!value.contains('@')) {
                                    return "Geçerli bir e posta giriniz";
                                  }
                                  return null;
                                },
                                onSaved: (mail) {}, // Kaldırdık
                                onChanged: (mail) {
                                  epostaController.text = mail;
                                  eposta = epostaController.text;
                                  epostaController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset: epostaController.text.length),
                                  );
                                },
                                controller: epostaController,

                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: SvgPicture.asset(
                                        "assets/icons/email.svg"),
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              "Şifre oluşturun",
                              style: TextStyle(color: Colors.black54),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 16),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Şifre alanı boş bırakılamaz.";
                                  } else if (value.length < 5) {
                                    return "Şifre en az 6 karater içermelidir";
                                  }
                                  return null;
                                },
                                onSaved: (password) {}, // Kaldırdık
                                onChanged: (password) {
                                  passwordController.text = password;
                                  sifre1 = passwordController.text;
                                  passwordController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset: passwordController.text.length),
                                  );
                                },
                                obscureText: true,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: SvgPicture.asset(
                                        "assets/icons/password.svg"),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 24),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  debugPrint('$sifre1');
                                  signUp(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF77D8E),
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(25),
                                      bottomRight: Radius.circular(25),
                                      bottomLeft: Radius.circular(25),
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_right,
                                  color: Color(0xFFFE0037),
                                ),
                                label: const Text(
                                  "Kayıt Ol",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      isShowLoading
                          ? CustomPositioned(
                              child: RiveAnimation.asset(
                                "assets/RiveAssets/check.riv",
                                onInit: (artboard) {
                                  StateMachineController controller =
                                      getRiveController(artboard);
                                  check =
                                      controller.findSMI("Check") as SMITrigger;
                                  error =
                                      controller.findSMI("Error") as SMITrigger;
                                  reset =
                                      controller.findSMI("Reset") as SMITrigger;
                                },
                              ),
                            )
                          : const SizedBox(),
                      isShowConfetti
                          ? CustomPositioned(
                              child: Transform.scale(
                                scale: 6,
                                child: RiveAnimation.asset(
                                  "assets/RiveAssets/confetti.riv",
                                  onInit: (artboard) {
                                    StateMachineController controller =
                                        getRiveController(artboard);
                                    confetti =
                                        controller.findSMI("Trigger explosion")
                                            as SMITrigger;
                                  },
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ));
  }

  void showVerificationDialog(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          title: Text('Onay Kodu'),
          content: Form(
            key: _formKey, // Form key'i ekleyin
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('E-posta adresinize gönderilen onay kodunu girin.'),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Onay kodu boş bırakılamaz.";
                    } else if (value.length != 6) {
                      return "Onay kodu 6 karakter içermelidir";
                    } else if (value != onaykod) {
                      return "Gönderilen onay kodu ile eşleşmiyor";
                    }
                    return null;
                  },
                  onSaved: (code) {}, // Kaldırdık
                  onChanged: (code) {
                    inputonaykod = code;
                  },

                  obscureText: true,
                  controller: CodeController,

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 247, 246, 246),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SvgPicture.asset("assets/icons/password.svg"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Builder(builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Onay kodunu kontrol et veya işlemleri gerçekleştir
                    if (inputonaykod == onaykod) {
                      DbInsert();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Kayıt Başarılı'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFFF77D8E),
                      ));
                      Navigator.of(context).pop();
                      // Dialog'u kapat
                      // İstenilen işlemleri gerçekleştir
                    } else {
                      // Yanlış onay kodu mesajı gösterilebilir

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Yanlış onay kodu!'),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  'Onayla',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF77D8E),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> sendEmail() async {
    try {
      String username =
          'scream.muhammedfethi@gmail.com'; // Gmail e-posta adresiniz
      String password = 'sztl mntz pwfe xkmo'; // Gmail şifreniz

      // E-posta içeriği
      var message = Message();
      message.from = Address(username.toString());
      message.recipients.add('$eposta'); // Alıcı e-posta adresi
      message.subject = 'VTYS Projesi Hesap Oluşturma Onay Kodu  Doğrulaması';
      message.text = 'Onay kodunuz: $onaykod';

      var smtpServer = gmail(username, password);
      send(message, smtpServer);
      debugPrint('E-posta gönderildi.');
    } catch (e) {
      debugPrint('${e.toString()}');
    }
  }

  void DbInsert() {
    if (eposta != null) {
      MongoDatabase.UsersInsert(
          "mongodb+srv://user123:user4455@cluster0.40yopgu.mongodb.net/PlaceMaps?retryWrites=true&w=majority",
          "Place",
          eposta!,
          sifre1!);
    }
  }

  Future<bool> DbMailControl(String epostadegeri) async {
    bool deger = await MongoDatabase.SingUpUsersControl(
        "mongodb+srv://user123:user4455@cluster0.40yopgu.mongodb.net/PlaceMaps?retryWrites=true&w=majority",
        "Place",
        epostadegeri.toString());
    if (deger == true) {
      debugPrint("Dış sorgu true");
      return deger;
    } else if (deger == false) {
      debugPrint("Dış sorgu false");
      return deger;
    } else {
      debugPrint("Dış sorgu belirsiz");
      return deger;
    }
  }
}

class CustomPositioned extends StatelessWidget {
  const CustomPositioned({Key? key, required this.child, this.size = 100})
      : super(key: key);
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          Spacer(),
          SizedBox(
            height: size,
            width: size,
            child: child,
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
