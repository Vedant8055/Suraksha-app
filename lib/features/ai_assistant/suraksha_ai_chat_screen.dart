import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/core/accessibility/accessibility.dart';
import 'package:suraksha_women_safety_app/features/ai_assistant/ai_service.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/cybercrime_screen.dart';
import 'package:suraksha_women_safety_app/features/maps/safety_map_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_chat_screen.dart';
import 'package:suraksha_women_safety_app/features/sos/sos_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class _ChatMessage {
  _ChatMessage({
    required this.text,
    required this.isUser,
    this.source,
    this.intent,
    this.actions = const [],
    this.usedFallback = false,
  });

  final String text;
  final bool isUser;
  final String? source;
  final String? intent;
  final List<String> actions;
  String? feedbackRating;
  final bool usedFallback;
}

class SurakshaAiChatScreen extends ConsumerStatefulWidget {
  const SurakshaAiChatScreen({super.key});

  @override
  ConsumerState<SurakshaAiChatScreen> createState() =>
      _SurakshaAiChatScreenState();
}

class _SurakshaAiChatScreenState extends ConsumerState<SurakshaAiChatScreen> {
  final _aiService = AIService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isSending = false;

  static const _accent = Color(0xFF7C5CFC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _messages.add(
          _ChatMessage(text: l10n.t('surakshaAiWelcome'), isUser: false),
        );
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<String> _quickPrompts(AppLocalizations l10n) => [
        l10n.t('surakshaAiQuickPrompt1'),
        l10n.t('surakshaAiQuickPrompt2'),
        l10n.t('surakshaAiQuickPrompt3'),
      ];

  Future<void> _sendMessage([String? preset]) async {
    final text = (preset ?? _messageController.text).trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isSending = true;
      if (preset == null) _messageController.clear();
    });
    _scrollToBottom();

    final result = await _aiService.getSafetyAdvice(text);
    if (!mounted) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: result.reply,
          isUser: false,
          source: result.source,
          intent: result.intent,
          actions: result.actions,
          usedFallback: result.usedFallback,
        ),
      );
      _isSending = false;
    });
    _scrollToBottom();
  }

  Future<void> _startNewConversation() async {
    final l10n = AppLocalizations.of(context);
    try {
      await _aiService.clearConversation();
    } catch (_) {
      // Local reset still helps even if network clear fails.
    }
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..add(_ChatMessage(text: l10n.t('surakshaAiWelcome'), isUser: false));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('surakshaAiConversationCleared'))),
    );
  }

  Future<void> _clearChat() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.t('surakshaAiClearChat')),
            content: Text(l10n.t('surakshaAiClearChatConfirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.t('cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.t('surakshaAiClearChat')),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    await _startNewConversation();
  }

  Future<void> _submitFeedback(int index, String rating) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _messages[index].feedbackRating = rating);
    try {
      await _aiService.sendFeedback(rating: rating);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('surakshaAiFeedbackThanks'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('surakshaAiFeedbackFailed'))),
      );
    }
  }

  Future<void> _runAction(String action) async {
    final l10n = AppLocalizations.of(context);
    switch (action) {
      case 'call_112':
        await launchUrl(Uri(scheme: 'tel', path: '112'));
        break;
      case 'trigger_sos':
        await ref.read(sosProvider.notifier).triggerSOS();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('surakshaAiSosTriggered'))),
        );
        break;
      case 'open_safety_map':
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SafetyMapScreen()),
        );
        break;
      case 'open_cyber':
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const CyberCrimeScreen()),
        );
        break;
      case 'open_posh':
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const POSHLegalPortalScreen(),
          ),
        );
        break;
    }
  }

  String _actionLabel(AppLocalizations l10n, String action) {
    switch (action) {
      case 'call_112':
        return l10n.t('surakshaAiActionCall112');
      case 'trigger_sos':
        return l10n.t('surakshaAiActionSos');
      case 'open_safety_map':
        return l10n.t('surakshaAiActionSafetyMap');
      case 'open_cyber':
        return l10n.t('surakshaAiActionCyber');
      case 'open_posh':
        return l10n.t('surakshaAiActionPosh');
      default:
        return action;
    }
  }

  String _intentLabel(AppLocalizations l10n, String? intent) {
    switch (intent) {
      case 'immediate_danger':
        return l10n.t('surakshaAiIntentDanger');
      case 'cyber_blackmail':
        return l10n.t('surakshaAiIntentCyber');
      case 'workplace_harassment':
        return l10n.t('surakshaAiIntentPosh');
      case 'medical_emergency':
        return l10n.t('surakshaAiIntentMedical');
      case 'greeting':
        return l10n.t('surakshaAiIntentGreeting');
      default:
        return l10n.t('surakshaAiIntentGeneral');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? const Color(0xFFF4F7FD) : AppTheme.backgroundColor;
    final surface = isLight ? Colors.white : AppTheme.cardColor;
    final textColor = isLight ? const Color(0xFF172235) : Colors.white;
    final muted = isLight ? const Color(0xFF627491) : Colors.white70;

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C5CFC), Color(0xFF4F8CFF)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('surakshaAi'),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    l10n.t('surakshaAiSubtitle'),
                    style: TextStyle(
                      color: muted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'new') {
                unawaitedSafe(_startNewConversation());
              } else if (value == 'clear') {
                unawaitedSafe(_clearChat());
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'new',
                child: Text(l10n.t('surakshaAiNewConversation')),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Text(l10n.t('surakshaAiClearChat')),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLight
                    ? const Color(0xFFEFF6FF)
                    : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                l10n.t('surakshaAiPrivacyWarning'),
                style: TextStyle(
                  color: isLight
                      ? const Color(0xFF1E3A5F)
                      : const Color(0xFFBFDBFE),
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              itemCount: _messages.length + (_isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isSending) {
                  return _buildTypingBubble(muted);
                }
                final message = _messages[index];
                final bubble = _buildBubble(
                  index: index,
                  message: message,
                  isLight: isLight,
                  textColor: textColor,
                  muted: muted,
                  l10n: l10n,
                );
                return Accessibility.motionAware(
                  context: context,
                  child: bubble,
                  animate: (child) => FadeInUp(
                    duration: const Duration(milliseconds: 260),
                    child: child,
                  ),
                );
              },
            ),
          ),
          if (!_isSending && _messages.length <= 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickPrompts(l10n)
                    .map(
                      (prompt) => ActionChip(
                        label: Text(prompt),
                        labelStyle: TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        backgroundColor:
                            _accent.withValues(alpha: isLight ? 0.10 : 0.18),
                        side: BorderSide(
                          color: _accent.withValues(alpha: 0.25),
                        ),
                        onPressed: () => _sendMessage(prompt),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: surface,
              border: Border(
                top: BorderSide(
                  color: isLight ? const Color(0xFFDCE5F6) : Colors.white12,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: l10n.t('surakshaAiPlaceholder'),
                      filled: true,
                      fillColor: isLight
                          ? const Color(0xFFF0F4FB)
                          : const Color(0xFF0F1728),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Semantics(
                  button: true,
                  enabled: !_isSending,
                  label: l10n.t('a11ySendMessage'),
                  child: Material(
                    color: _accent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: _isSending ? null : () => _sendMessage(),
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: Accessibility.minTouchTarget,
                        height: Accessibility.minTouchTarget,
                        child: _isSending
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble({
    required int index,
    required _ChatMessage message,
    required bool isLight,
    required Color textColor,
    required Color muted,
    required AppLocalizations l10n,
  }) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.88,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF4F8CFF), Color(0xFF7C5CFC)],
                )
              : null,
          color: isUser
              ? null
              : isLight
                  ? Colors.white
                  : const Color(0xFF121C30),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 18),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: isLight ? const Color(0xFFDCE5F6) : Colors.white12,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : textColor,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isUser && message.usedFallback) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.t('surakshaAiLimitedOfflineGuidance'),
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
            if (!isUser &&
                message.intent != null &&
                message.intent != 'greeting' &&
                index > 0) ...[
              const SizedBox(height: 6),
              Text(
                _intentLabel(l10n, message.intent),
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (!isUser && message.actions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.actions
                    .map(
                      (action) => OutlinedButton(
                        onPressed: () => _runAction(action),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _accent,
                          side: BorderSide(
                            color: _accent.withValues(alpha: 0.45),
                          ),
                          minimumSize: const Size(48, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          _actionLabel(l10n, action),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            if (!isUser && index > 0) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: [
                  _FeedbackChip(
                    label: l10n.t('surakshaAiFeedbackHelpful'),
                    selected: message.feedbackRating == 'helpful',
                    onTap: () => _submitFeedback(index, 'helpful'),
                  ),
                  _FeedbackChip(
                    label: l10n.t('surakshaAiFeedbackIrrelevant'),
                    selected: message.feedbackRating == 'irrelevant',
                    onTap: () => _submitFeedback(index, 'irrelevant'),
                  ),
                  _FeedbackChip(
                    label: l10n.t('surakshaAiFeedbackUnsafe'),
                    selected: message.feedbackRating == 'unsafe',
                    onTap: () => _submitFeedback(index, 'unsafe'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBubble(Color muted) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF121C30),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: muted),
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context).t('surakshaAiThinking'),
              style: TextStyle(
                color: muted,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackChip extends StatelessWidget {
  const _FeedbackChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF7C5CFC).withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFF7C5CFC)
                : const Color(0xFF94A3B8).withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected
                ? const Color(0xFF7C5CFC)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

void unawaitedSafe(Future<void> future) {
  future.then((_) {}, onError: (_) {});
}
