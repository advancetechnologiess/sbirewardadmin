import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IntentUtils{


  static void fireIntent(BuildContext context, dynamic classobj) {

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => classobj),
          (Route<dynamic> route) => false,
    );
    // Navigator.of(context).pushReplacement(MaterialPageRoute(
    //     builder: (BuildContext c) => classobj));
  }

  static void fireIntentwithoutFinish(BuildContext context, dynamic classobj)
  {
    Navigator.of(context).push(MaterialPageRoute<dynamic>(
      builder: (BuildContext context) {
        return classobj;
      },
    )
    );
  }

  static void fireIntentwithAnimations(BuildContext context, dynamic classobj,bool finishall)
  {
    if(finishall)
    {
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => classobj),
      //       (Route<dynamic> route) => false,
      // );

      Navigator.of(context).pushReplacement(PageRouteBuilder(
        // transitionDuration: Duration(seconds: 2),
          pageBuilder: (_, __, ___) => classobj));
    }
    else{
      Navigator.of(context).push(PageRouteBuilder(
        // transitionDuration: Duration(seconds: 2),
        pageBuilder: (_, __, ___) {
          return classobj;
        },
      )
      );
    }
  }
}