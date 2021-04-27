import 'package:flutter/material.dart';

class Lables extends StatelessWidget {
  final String ruta;
  final String titulo;
  final String subtitulo;

  const Lables({
    Key key,
    @required this.ruta,
    @required this.titulo,
    @required this.subtitulo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(this.titulo,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w300)),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, this.ruta);
            },
            child: Text(
              this.subtitulo,
              style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          )
        ],
      ),
    );
  }
}
