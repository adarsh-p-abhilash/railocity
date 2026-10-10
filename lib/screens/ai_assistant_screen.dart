import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../services/ai_agent_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ticket_pass_card.dart';

class AIAssistantScreen extends StatefulWidget {
  final AIAgentService aiAgentService;
  final VoidCallback onNavigateToLive;
  final VoidCallback onNavigateToTickets;

  const AIAssistantScreen({
    super.key,
    required this.aiAgentService,
    required this.onNavigateToLive,
    required this.onNavigateToTickets,
  });

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? text]) {
    final query = text ?? _inputController.text;
    if (query.trim().isEmpty) return;
    _inputController.clear();
    widget.aiAgentService.handleUserInput(query);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.aiAgentService,
      builder: (context, _) {
        final messages = widget.aiAgentService.messages;
        final isProcessing = widget.aiAgentService.isProcessing;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Railo AI Companion', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Automated Booking & Intelligence',
                          style: TextStyle(fontSize: 10, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Quick Info',
                icon: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                onPressed: () => _showAgentCapabilitiesModal(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Chat conversation list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageItem(msg);
                  },
                ),
              ),

              // Bottom suggestion chips row
              _buildSuggestedChipsBar(),

              // Input bar
              _buildInputArea(isProcessing),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    final isUser = msg.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isUser ? AppColors.primaryLight : AppColors.border,
                    ),
                  ),
                  child: msg.isThinking
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                            ),
                            SizedBox(width: 10),
                            Text('Railo AI is querying IRCTC & Telemetry...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        )
                      : Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: isUser ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                ),
              ),
              if (isUser) const SizedBox(width: 8),
            ],
          ),

          // Reasoning steps visualization
          if (msg.reasoningSteps != null && msg.reasoningSteps!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 32),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.checklist_rounded, size: 14, color: AppColors.secondary),
                      SizedBox(width: 6),
                      Text(
                        'Autonomous Agent Workflow Execution:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...msg.reasoningSteps!.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        step,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Embedded Ticket Card if AI booked ticket
          if (msg.bookingCard != null)
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 32),
              child: TicketPassCard(
                booking: msg.bookingCard!,
                onTrackTrain: widget.onNavigateToLive,
              ),
            ),

          // Suggested Chips inside AI response
          if (msg.suggestedChips.isNotEmpty && !isUser)
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 32),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: msg.suggestedChips.map((chip) {
                  return ActionChip(
                    backgroundColor: AppColors.surfaceLight,
                    side: const BorderSide(color: AppColors.borderHighlight),
                    label: Text(chip, style: const TextStyle(fontSize: 11, color: AppColors.accent)),
                    onPressed: () => _sendMessage(chip),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestedChipsBar() {
    final chips = [
      '⚡ Book ticket to Mumbai',
      '⏱️ When is my train arriving?',
      '🚉 Which platform is coach B3?',
      '⚠️ Check delays on route',
      '🍽️ Pantry food menu',
    ];

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return InkWell(
            onTap: () => _sendMessage(chips[i]),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderHighlight),
              ),
              child: Center(
                child: Text(
                  chips[i],
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(bool isProcessing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                textInputAction: TextInputAction.send,
                onSubmitted: isProcessing ? null : (_) => _sendMessage(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ask Railo AI or say "Book ticket to Mumbai"...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                onPressed: isProcessing ? null : () => _sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgentCapabilitiesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Railo AI Capabilities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.bolt, color: AppColors.secondary),
                title: Text('Automated 1-Click Ticket Booking', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text('Parses natural language, checks quota, allocates seats, and confirms PNRs.'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.timer_outlined, color: AppColors.accent),
                title: Text('Live ETA & Boarding Countdown', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text('Tells you down to the second when the train arrives at your station.'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.train, color: AppColors.success),
                title: Text('Platform & Coach Positioning', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text('Guides you to exact platform positions relative to station bridges and escalators.'),
              ),
            ],
          ),
        );
      },
    );
  }
}
