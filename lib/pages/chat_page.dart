import 'dart:io';

import 'package:chat/models/mensajes_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';

import 'package:chat/widgets/chat_message.dart';

import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _ctrlText = TextEditingController();
  final _focusNode = FocusNode();
  bool _estaEscribiendo = false;

  ChatService chatService;
  SocketService socketService;
  AuthService authService;
  List<ChatMessage> _messages = [];

  @override
  @override
  void initState() {
    super.initState();
    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);
    this.socketService.socket.on('mensaje-personal', _escucharMensaje);

    _cargarHistorial(this.chatService.usuarioPara.uid);
  }

  void _escucharMensaje(dynamic payload) {
    ChatMessage message = ChatMessage(
        texto: payload['mensaje'],
        uid: payload['de'],
        animationController: new AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 200),
        ));
    _messages.insert(0, message);
    setState(() {});
    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            CircleAvatar(
              child: Text(
                chatService.usuarioPara.nombre.substring(0, 2),
                style: TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
            ),
            SizedBox(height: 3),
            Text(
              chatService.usuarioPara.nombre,
              style: TextStyle(color: Colors.black87, fontSize: 12),
            )
          ],
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemBuilder: (_, i) => _messages[i],
                reverse: true,
                itemCount: _messages.length,
              ),
            ),
            Divider(height: 1),
            Container(
              color: Colors.white,
              //height: 100,
              child: _inputChat(),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _ctrlText,
                onSubmitted: _handleSummit,
                onChanged: (String texto) {
                  setState(() {
                    if (texto.trim().length > 0) {
                      this._estaEscribiendo = true;
                    } else {
                      this._estaEscribiendo = false;
                    }
                  });
                },
                decoration: InputDecoration.collapsed(
                  hintText: 'Enviar mensaje',
                ),
                focusNode: _focusNode,
              ),
            ),
            //Boton Enviar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Platform.isIOS
                  ? CupertinoButton(
                      child: Text('Enviar'),
                      onPressed: this._estaEscribiendo
                          ? () => _handleSummit(_ctrlText.text)
                          : null,
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: IconTheme(
                        data: IconThemeData(color: Colors.blue[400]),
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: Icon(
                            Icons.send,
                          ),
                          onPressed: this._estaEscribiendo
                              ? () => _handleSummit(_ctrlText.text)
                              : null,
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  _handleSummit(String texto) {
    if (texto.length == 0) return;

    _ctrlText.clear();
    _focusNode.requestFocus();

    final newMessage = ChatMessage(
      uid: authService.usuario.uid,
      texto: texto,
      animationController: AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
      ),
    );

    _messages.insert(0, newMessage);
    newMessage.animationController.forward();

    setState(() {
      _estaEscribiendo = false;
    });

    this.socketService.emit('mensaje-personal', {
      'de': authService.usuario.uid,
      'para': this.chatService.usuarioPara.uid,
      'mensaje': texto
    });
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }

    this.socketService.socket.off('mensaje-personal');

    super.dispose();
  }

  void _cargarHistorial(String uid) async {
    List<Mensaje> chat = await ChatService().getChat(uid);

    final history = chat.map(
      (e) => new ChatMessage(
        texto: e.mensaje,
        uid: e.de,
        animationController: new AnimationController(
            vsync: this, duration: Duration(milliseconds: 0))
          ..forward(),
      ),
    );

    setState(() {
      _messages.insertAll(0, history);
    });
  }
}
