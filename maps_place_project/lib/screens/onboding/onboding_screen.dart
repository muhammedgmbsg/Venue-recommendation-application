import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive_animation/screens/onboding/components/animated_btn.dart';
import 'package:rive_animation/screens/onboding/components/custom_sign_in.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool isSignInDialogShown = false;
  late RiveAnimationController _btnAnimationController;

  @override
  void initState() {
    _btnAnimationController = OneShotAnimation("active", autoplay: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Geri tuşu kullanımını kontrol etmek istediğiniz koşulları burada belirtin.
        // Eğer geri tuşunu devre dışı bırakmak istiyorsanız `false` döndürün.
        return false;
      },
      child: Scaffold(
          body: Stack(
        children: [
          Positioned(
              width: MediaQuery.of(context).size.width * 1.7,
              bottom: 200,
              left: 100,
              child: Image.asset('assets/Backgrounds/Spline.png')),
          Positioned.fill(
              child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 10),
          )),
          const RiveAnimation.asset('assets/RiveAssets/shapes.riv'),
          Positioned.fill(
              child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 10),
            child: const SizedBox(),
          )),
          AnimatedPositioned(
            duration: Duration(milliseconds: 240),
            top: isSignInDialogShown ? -50 : 0,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(),
                      const SizedBox(
                        width: 260,
                        child: Column(children: [
                          Text(
                            "Mekan Öneri \nProjesi",
                            style: TextStyle(
                                fontSize: 45,
                                fontFamily: "Poppins",
                                height: 1.2),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 0),
                            child: Text(
                              'Nasıl Çalışır?\nBir il seçin,semt seçin ve aratmak istediğiniz mekanı girin.Artık bütün bilgiler sizinle! Mekanlarınızı favorileyerek daha sonra erişebilirsiniz.',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 48, 48, 48),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  fontFamily: CupertinoIcons.iconFont),
                            ),
                          ),
                        ]),
                      ),
                      const Spacer(
                        flex: 2,
                      ),
                      AnimatedBtn(
                        btnAnimationController: _btnAnimationController,
                        press: () {
                          _btnAnimationController.isActive = true;
                          Future.delayed(Duration(milliseconds: 800), () {
                            setState(() {
                              isSignInDialogShown = true;
                            });
                            customSigninDialog(context, onClosed: (_) {
                              setState(() {
                                isSignInDialogShown = false;
                              });
                            });
                          });
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          "Tam 208 ülkede binlerce şehirden isteğiniz konumdaki mekanlara erişerek sizlere daha iyi bir hizmet vermeye çalışıyoruz !",
                          style: TextStyle(),
                        ),
                      )
                    ]),
              ),
            ),
          )
        ],
      )),
    );
  }
}
