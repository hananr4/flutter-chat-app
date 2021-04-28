import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

mostrarAlerta(BuildContext context, String titulo, String contenido) {
  if (Platform.isAndroid) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(contenido),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Ok'),
            elevation: 5,
            textColor: Colors.blue,
          )
        ],
      ),
    );
  }
  return showCupertinoDialog(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: Text(titulo),
      content: Text(contenido),
      actions: [
        CupertinoDialogAction(
          child: Text('Ok'),
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
        )
      ],
    ),
  );
}
