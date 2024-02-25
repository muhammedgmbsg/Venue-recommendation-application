import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rive_animation/loginApi.dart';

import 'package:rive_animation/screens/onboding/components/sign_in_form.dart';

Future<Object?> customSigninDialog(BuildContext context,
    {required ValueChanged onClosed}) {
  return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "Giriş Yap",
      context: context,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        Tween<Offset> tween = Tween(begin: Offset(0, -1), end: Offset.zero);
        return SlideTransition(
            position: tween.animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child);
      },
      pageBuilder: (context, _, __) => Center(
            child: SingleChildScrollView(
              child: Container(
                height:
                    MediaQuery.of(context).size.height < 700 ? 700.h : 600.h,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: const BorderRadius.all(Radius.circular(40))),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  resizeToAvoidBottomInset:
                      false, // avoid overflow error when keyboard shows up
                  body: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(children: [
                        const Text(
                          "Giriş Yap",
                          style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "Lütfen bilgilerinizi doğru ve eksiksiz giriniz !",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SignInForm(),
                        const Row(
                          children: [
                            Expanded(
                              child: Divider(),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "Hesabın yok mu",
                                style: TextStyle(color: Colors.black26),
                              ),
                            ),
                            Expanded(
                              child: Divider(),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          child: Text("Kayıt ol",
                              style: TextStyle(color: Colors.black54)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => SignUpForm(),
                                  ));
                                },
                                icon: SvgPicture.asset(
                                  "assets/icons/email_box.svg",
                                  height: 44.h,
                                  width: 44.w,
                                )),
                          ],
                        )
                      ]),
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: -48,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.close, color: Colors.black),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )).then(onClosed);
}
