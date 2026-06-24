import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../services/ai_coach.dart';
import '../theme/app_theme.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});
  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _ChatMsg {
  final String text;
  final bool fromUser;
  _ChatMsg(this.text, this.fromUser);
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_ChatMsg> _log = [];

  static const _quick = [
    'Can I buy this?',
    'Which loan should I pay?',
    'How much can I spend?',
    'What should I do with my bonus?',
    'Which loan should I close first?',
    'How much interest can I save?',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _log.add(_ChatMsg(
            "Hi! Ask me anything before you spend — I know your loans and income.",
            false,
          )));
    });
  }

  void _send([String? preset]) {
    final text = preset ?? _input.text.trim();
    if (text.isEmpty) return;
    final d = context.read<AppState>().data;
    setState(() {
      _log.add(_ChatMsg(text, true));
      _input.clear();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _log.add(_ChatMsg(AiCoach.reply(d, text), false)));
      _scroll.animateTo(_scroll.position.maxScrollExtent + 80, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(children: const [
            Text('AI Coach', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ]),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: _quick
                .map((q) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(q, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                        onPressed: () => _send(q),
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            itemCount: _log.length,
            itemBuilder: (_, i) {
              final m = _log[i];
              return Align(
                alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: m.fromUser ? AppColors.brand : AppColors.surface,
                    border: m.fromUser ? null : Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(m.fromUser ? 14 : 4),
                      bottomRight: Radius.circular(m.fromUser ? 4 : 14),
                    ),
                  ),
                  child: Text(m.text, style: TextStyle(fontSize: 13.5, color: m.fromUser ? Colors.white : AppColors.text, height: 1.4)),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  decoration: InputDecoration(
                    hintText: 'Ask the AI coach…',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.brand,
                child: IconButton(icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18), onPressed: () => _send()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
