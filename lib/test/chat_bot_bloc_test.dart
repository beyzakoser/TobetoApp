// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/constant_padding.dart';
import 'package:flutter_application_1/logic/blocs/chat/chat_bloc.dart';
import 'package:flutter_application_1/logic/blocs/chat/chat_event.dart';
import 'package:flutter_application_1/logic/blocs/chat/chat_state.dart';
import 'package:flutter_application_1/models/chat_bot_model.dart';
import 'package:flutter_application_1/test/chat_bot_test.dart';
import 'package:flutter_application_1/widgets/home_page/tabbar_widgets/custom_widget/custom_circular_progress.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class ChatBotBlocTest extends StatefulWidget {
  final String uid;
  String? discussionId;
  ChatBotBlocTest({
    super.key,
    required this.uid,
    this.discussionId,
  });

  @override
  State<ChatBotBlocTest> createState() => _ChatBotBlocTestState();
}

class _ChatBotBlocTestState extends State<ChatBotBlocTest> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // initState içinde ChatResetEvent tetikleniyor
    context.read<ChatBloc>().add(ChatResetEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Chat Bot Bloc Test'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(
                  context, true); // Geri dönüş değeri true olarak ayarlandı
            },
          )),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatInitialState) {
            print("ChatInitialState");
            if (widget.discussionId == null) {
              print("ChatInitialState - widget.discussionId == null");
              context.read<ChatBloc>().add(ChatEmptyDiscussionEvent());
            } else {
              print("ChatInitialState - widget.discussionId != null");
              context.read<ChatBloc>().add(ChatFetchEvent(
                  uid: widget.uid, discussionId: widget.discussionId!));
            }
          } else if (state is ChatFetchLoadingState) {
            print("ChatFetchLoadingState");
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ChatFetchedState) {
            print("ChatFetchedState");
            return ChatHistoryWidget(
              chatMessages: state.chatMessages,
              messageController: _messageController,
              widget: widget,
              onPressed: () {
                context.read<ChatBloc>().add(ChatAddMessageEvent(
                      message: _messageController.text,
                      uid: widget.uid,
                    ));
                context.read<ChatBloc>().add(ChatFetchResponseEvent(
                      uid: widget.uid,
                      message: _messageController.text,
                    ));
                _messageController.clear();
              },
            );
          } else if (state is ChatFetchErrorState) {
            print("ChatFetchErrorState");
            return Center(
              child: Center(child: Text(state.errorMessage)),
            );
          } else if (state is ChatEmptyDiscussion) {
            print("EmptyDiscussion");
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: FlutterLogo(size: 100)),
                      SizedBox(height: 20),
                      Text("İlk mesajınızı yazın"),
                    ],
                  ),
                ),
                ChatTextField(
                    messageController: _messageController,
                    onPressed: () {
                      context.read<ChatBloc>().add(ChatAddFirstMessageEvent());
                      context.read<ChatBloc>().add(ChatAddMessageEvent(
                            message: _messageController.text,
                            uid: widget.uid,
                          ));
                      context.read<ChatBloc>().add(ChatFetchResponseEvent(
                            uid: widget.uid,
                            message: _messageController.text,
                          ));
                      _messageController.clear();
                    }),
              ],
            );
          } else if (state is ChatFirstMessageAddedState) {
            print("ChatFirstMessageAddedState");
          }
          return const Center(child: Text("de"));
        },
      ),
    );
  }
}

class ChatHistoryWidget extends StatelessWidget {
  final List<ChatBotMessageModel>? chatMessages;
  final void Function()? onPressed;
  const ChatHistoryWidget({
    super.key,
    required TextEditingController messageController,
    required this.widget,
    this.chatMessages,
    required this.onPressed,
  }) : _messageController = messageController;

  final TextEditingController _messageController;
  final ChatBotBlocTest widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.75,
          color: Colors.grey[200],
          child: chatMessages == null
              ? Container()
              : ListView.builder(
                  reverse: true,
                  itemCount: chatMessages!.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ChatCard(
                          message: chatMessages![index].prompt!,
                          name: "Öğrenci",
                          time: "12:00",
                        ),
                        chatMessages![index].response == null
                            ? const CustomCircularProgress()
                            : ChatCard(
                                message: chatMessages![index].response!,
                                name: "TobetoAI",
                                time: "12:01",
                              ),
                      ],
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        ChatTextField(
            messageController: _messageController, onPressed: onPressed),
      ],
    );
  }
}

class ChatTextField extends StatelessWidget {
  const ChatTextField({
    super.key,
    required TextEditingController messageController,
    required this.onPressed,
  }) : _messageController = messageController;

  final TextEditingController _messageController;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: paddingAllMedium,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Mesajınızı yazın',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
