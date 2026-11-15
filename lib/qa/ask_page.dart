// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:passkeys_presentation/qa/passkey_auth.dart';
import 'package:passkeys_presentation/shared/brand.dart';
import 'package:passkeys_presentation/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lets a signed in member of the audience post questions and remove their
/// own.
class AskPage extends StatefulWidget {
  const AskPage({required this.user, super.key});

  final User user;

  @override
  State<AskPage> createState() => _AskPageState();
}

class _AskPageState extends State<AskPage> {
  final _supabase = Supabase.instance.client;
  final _controller = TextEditingController();
  late final Stream<List<QuestionsRow>> _myQuestions = _supabase
      .table(Questions.table)
      .stream(primaryKey: [Questions.id])
      .filter(Questions.userId.eq(widget.user.id))
      .order(Questions.createdAt.desc());
  bool _sending = false;

  String get _name => displayNameOf(widget.user);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _supabase
          .table(Questions.table)
          .insert(QuestionsInsert(authorName: _name, content: content));
      _controller.clear();
      _showMessage('Sent! Look at the big screen.');
    } on SupabaseException catch (error) {
      _showMessage('Could not send the question: ${error.message}');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _delete(QuestionsRow question) async {
    try {
      await _supabase
          .table(Questions.table)
          .delete()
          .where(Questions.id.eq(question.id));
    } on SupabaseException catch (error) {
      _showMessage('Could not delete the question: ${error.message}');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi $_name'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => _supabase.auth.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Brand.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user, color: Brand.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Signed in with a passkey. No password was involved.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  enabled: !_sending,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 280,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'What would you like to know about passkeys?',
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _sending ? null : _send,
                  icon: _sending
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Ask'),
                ),
                const SizedBox(height: 32),
                Text('Your questions', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                StreamBuilder(
                  stream: _myQuestions,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'Could not load your questions: ${snapshot.error}',
                        style: const TextStyle(color: Brand.mutedText),
                      );
                    }
                    final questions = snapshot.data ?? const [];
                    if (questions.isEmpty) {
                      return const Text(
                        'Nothing yet.',
                        style: TextStyle(color: Brand.mutedText),
                      );
                    }
                    return Column(
                      children: [
                        for (final question in questions)
                          Card(
                            color: Brand.surface,
                            child: ListTile(
                              title: Text(question.content),
                              trailing: IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _delete(question),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
