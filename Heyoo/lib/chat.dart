import 'package:flutter/material.dart';
// import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Chat extends StatefulWidget {
  final String user;

  const Chat({Key? key, required this.user}) : super(key: key);

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _controller = ScrollController();
  late IO.Socket socket;

  void _sendMessage() {
    String messageText = _messageController.text.trim();
    _messageController.text = '';
    print(messageText);
    if (messageText.isNotEmpty) {
      var messagePost = {
        'message': messageText,
        'sender': widget.user,
        'recipient': 'chat',
        'time': DateTime.now().toUtc().toString().substring(0, 16),
      };
      socket.emit('chat', messagePost);
    }
  }

  @override
  void initState() {
    super.initState();
    initSocket();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    });
  }

  Future<void> initSocket() async {
    // Define your getFCMToken logic or import it here
    socket = IO.io(
      'http://localhost:3000/',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );
    socket.connect();
    socket.onConnect((_) {
      print('connected to websocket');
    });
    socket.on('newChat', (message) {
      setState(() {
        print(message);
      });
    });
    socket.on('allChats', (messages) {
      print(messages);
      setState(() {
        print(messages);
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Chat',
          style: TextStyle(fontSize: 15, color: Colors.white),
          textAlign: TextAlign.left,
        ),
      ),
      body: Stack(
        children: [
          // Positioned(
          //   top: 0,
          //   bottom: 60,
          //   width: size.width,
          //   child: ListView.builder(
          //     controller: _controller,
          //     scrollDirection: Axis.vertical,
          //     shrinkWrap: true,
          //     reverse: true,
          //     cacheExtent: 1000,
          //     itemCount: MessagesModel.messages.length,
          //     itemBuilder: (BuildContext context, int index) {
          //       var message = MessagesModel
          //           .messages[MessagesModel.messages.length - index - 1];
          //       return (message['sender'] == widget.user)
          //           ? ChatBubble(
          //               clipper:
          //                   ChatBubbleClipper1(type: BubbleType.sendBubble),
          //               alignment: Alignment.topRight,
          //               margin: const EdgeInsets.only(top: 5, bottom: 5),
          //               backGroundColor: Colors.yellow[100],
          //               child: Container(
          //                 constraints:
          //                     BoxConstraints(maxWidth: size.width * 0.7),
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     Text(
          //                       '@${message['time']}',
          //                       style:
          //                           const TextStyle(color: Colors.grey, fontSize: 10),
          //                     ),
          //                     Text(
          //                       '${message['message']}',
          //                       style:const  TextStyle(
          //                           color: Colors.black, fontSize: 16),
          //                     )
          //                   ],
          //                 ),
          //               ),
          //             )
          //           : ChatBubble(
          //               clipper:
          //                   ChatBubbleClipper1(type: BubbleType.receiverBubble),
          //               alignment: Alignment.topLeft,
          //               margin:const  EdgeInsets.only(top: 5, bottom: 5),
          //               backGroundColor: Colors.grey[100],
          //               child: Container(
          //                 constraints:
          //                     BoxConstraints(maxWidth: size.width * 0.7),
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     Text(
          //                       '${message['sender']} @${message['time']}',
          //                       style:
          //                         const  TextStyle(color: Colors.grey, fontSize: 10),
          //                     ),
          //                     Text(
          //                       '${message['message']}',
          //                       style: const TextStyle(
          //                           color: Colors.black, fontSize: 16),
          //                     )
          //                   ],
          //                 ),
          //               ),
          //             );
          //     },
          //   ),
          // ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 60,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.80,
                    padding: const EdgeInsets.only(left: 10, right: 5),
                    child: TextField(
                      controller: _messageController,
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        hintText: "Message",
                        labelStyle:
                            TextStyle(fontSize: 15, color: Colors.black),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        counterText: '',
                      ),
                      style: const TextStyle(fontSize: 15),
                      keyboardType: TextInputType.text,
                      maxLength: 500,
                    ),
                  ),
                  Container(
                    width: size.width * 0.20,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.redAccent),
                      iconSize: 30,
                      onPressed: () {
                        _sendMessage();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
