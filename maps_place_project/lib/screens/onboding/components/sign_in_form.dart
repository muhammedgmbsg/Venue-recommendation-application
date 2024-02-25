import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rive/rive.dart';
import 'package:rive_animation/SearchScreen.dart';

import '../../../mongodb.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({
    super.key,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
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

  Future<void> signIn(BuildContext context) async {
    setState(() {
      isShowLoading = true;
      isShowConfetti = true;
    });
    bool giriskontrol = await DbGirisControl(eposta!, sifre!);
    Future.delayed(Duration(seconds: 1), () {
      if (_formKey.currentState!.validate() && giriskontrol == true) {
        // show success
        check.fire();
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isShowLoading = false;
          });
          confetti.fire();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SearchScreen(eposta: eposta!, sifre: sifre!),
          ));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Girdiğiniz bilgilere ait bir hesap bulunamadı!'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFF77D8E),
        ));
        error.fire();

        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isShowLoading = false;
          });
        });
      }
    });
  }

  TextEditingController epostacontoller = TextEditingController();
  TextEditingController passwordcontoller = TextEditingController();
  String? eposta;
  String? sifre;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "E postanızı girin",
                  style: TextStyle(color: Colors.black54),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "E-posta alanı boş bırakılamaz.";
                      } else if (!value.contains('@')) {
                        return "Geçerli bir e posta giriniz";
                      }
                      return null;
                    },
                    onSaved: (email) {},
                    onChanged: (value) {
                      epostacontoller.text = value;
                      eposta = epostacontoller.text;
                      epostacontoller.selection = TextSelection.fromPosition(
                        TextPosition(offset: epostacontoller.text.length),
                      );
                    },
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SvgPicture.asset("assets/icons/email.svg"),
                    )),
                  ),
                ),
                const Text(
                  "Şifrenizi girin",
                  style: TextStyle(color: Colors.black54),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Şifre alanı boş bırakılamaz.";
                      } else if (value.length < 5) {
                        return "Şifre en az 6 karater içermelidir";
                      }
                      return null;
                    },
                    onSaved: (password) {},
                    onChanged: (value) {
                      passwordcontoller.text = value;
                      sifre = passwordcontoller.text;
                      passwordcontoller.selection = TextSelection.fromPosition(
                        TextPosition(offset: passwordcontoller.text.length),
                      );
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SvgPicture.asset("assets/icons/password.svg"),
                    )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                  child: ElevatedButton.icon(
                      onPressed: () {
                        signIn(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF77D8E),
                          minimumSize: const Size(double.infinity, 56),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                  bottomLeft: Radius.circular(25)))),
                      icon: const Icon(
                        CupertinoIcons.arrow_right,
                        color: Color(0xFFFE0037),
                      ),
                      label: const Text(
                        "Giriş Yap",
                        style: TextStyle(color: Colors.white),
                      )),
                )
              ],
            )),
        isShowLoading
            ? CustomPositioned(
                child: RiveAnimation.asset(
                "assets/RiveAssets/check.riv",
                onInit: (artboard) {
                  StateMachineController controller =
                      getRiveController(artboard);
                  check = controller.findSMI("Check") as SMITrigger;
                  error = controller.findSMI("Error") as SMITrigger;
                  reset = controller.findSMI("Reset") as SMITrigger;
                },
              ))
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
                        controller.findSMI("Trigger explosion") as SMITrigger;
                  },
                ),
              ))
            : const SizedBox()
      ],
    );
  }

  Future<bool> DbGirisControl(String epostadegeri, String sifredegeri) async {
    bool deger = await MongoDatabase.LoginUsersControl(
        "mongodb+srv://user123:user4455@cluster0.40yopgu.mongodb.net/PlaceMaps?retryWrites=true&w=majority",
        "Place",
        epostadegeri.toString(),
        sifredegeri.toString());
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
  const CustomPositioned({super.key, required this.child, this.size = 100});
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
