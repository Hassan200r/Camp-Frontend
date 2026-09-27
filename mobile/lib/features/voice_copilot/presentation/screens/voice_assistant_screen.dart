import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CAMP Voice Copilot Screen
/// Specialized hands-free expedition voice assistant for motorcyclists and field mechanics.
class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

enum CopilotState {
  idle,
  listening,
  processing,
  responding,
  error,
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  CopilotState _state = CopilotState.listening;
  String _activeCommandFeedback = '';
  String _errorMessage = '';
  String _liveTranscript = '';
  bool _isStreamingTranscript = false;
  Timer? _transcriptTimer;
  int _simulationIndex = 0;
  bool _isOfflineMode = false;

  final List<String> _simulatedPhrases = const [
    'Find a mechanic near Babusar Pass',
    'Check tire pressure & chain slack',
    'Navigate to Hunza Valley via KKH',
    'How far to next high-octane fuel?',
  ];

  bool get _isListening => _state == CopilotState.listening;
  bool get _isProcessing => _state == CopilotState.processing;
  bool get _isResponding => _state == CopilotState.responding;
  bool get _isError => _state == CopilotState.error;
  bool get _isIdle => _state == CopilotState.idle;

  final List<_QuickCommand> _commands = const [
    _QuickCommand(
      icon: Icons.vpn_key_rounded,
      title: '"Find a mechanic near Babusar Pass"',
      accentColor: Color(0xFFF97316),
      badgeBg: Color(0xFF261911),
      badgeBorder: Color(0xFF5A2A14),
      responseMessage:
          'Locating mechanics near Babusar Pass (N-15)... Found 2 active field mechanics within 18 km.',
    ),
    _QuickCommand(
      icon: Icons.add_circle_outline_rounded,
      title: '"Check tire pressure & chain slack"',
      accentColor: Color(0xFF38BDF8),
      badgeBg: Color(0xFF0C2436),
      badgeBorder: Color(0xFF0369A1),
      responseMessage:
          'Front: 32 PSI (Optimal), Rear: 36 PSI (Optimal). Chain slack: 28 mm within safe tolerance.',
    ),
    _QuickCommand(
      icon: Icons.map_outlined,
      title: '"Navigate to Hunza Valley via KKH"',
      accentColor: Color(0xFF34D399),
      badgeBg: Color(0xFF07261C),
      badgeBorder: Color(0xFF065F46),
      responseMessage:
          'Plotting route: Karakoram Highway (N-35) to Karimabad, Hunza. Total distance 284 km. Weather clear.',
    ),
    _QuickCommand(
      icon: Icons.local_gas_station_rounded,
      title: '"How far to next high-octane fuel?"',
      accentColor: Color(0xFFFBBF24),
      badgeBg: Color(0xFF2A200B),
      badgeBorder: Color(0xFF78350F),
      responseMessage:
          'Nearest HOBC/High-Octane station is PSO Chilas, 34 km ahead. Fuel reserve safe.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Pulse animation for central microphone concentric rings
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Waveform equalizer continuous animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Initial state setup & start listening simulation
    _transitionTo(CopilotState.listening);
    _startLiveTranscriptSimulation();
  }

  @override
  void dispose() {
    _cancelTranscriptSimulation();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startLiveTranscriptSimulation([String? specificPhrase]) {
    _cancelTranscriptSimulation();
    final phrase = specificPhrase ?? _simulatedPhrases[_simulationIndex % _simulatedPhrases.length];
    _simulationIndex++;

    final words = phrase.split(' ');
    int wordIndex = 0;
    _liveTranscript = '';
    _isStreamingTranscript = true;

    _transcriptTimer = Timer.periodic(const Duration(milliseconds: 320), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (wordIndex < words.length) {
        setState(() {
          _liveTranscript += (wordIndex == 0 ? '' : ' ') + words[wordIndex];
          wordIndex++;
        });
      } else {
        timer.cancel();
        _isStreamingTranscript = false;
        setState(() {});
        // Settle briefly before processing so rider sees complete query
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted || _state != CopilotState.listening) return;
          _processPhrase(_liveTranscript);
        });
      }
    });
  }

  void _cancelTranscriptSimulation() {
    _transcriptTimer?.cancel();
    _transcriptTimer = null;
    _isStreamingTranscript = false;
  }

  _QuickCommand _resolveCommandForQuery(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('mechanic') ||
        lower.contains('babusar') ||
        lower.contains('pass') ||
        lower.contains('repair') ||
        lower.contains('garage')) {
      return _commands[0];
    } else if (lower.contains('tire') ||
        lower.contains('pressure') ||
        lower.contains('chain') ||
        lower.contains('slack') ||
        lower.contains('psi')) {
      return _commands[1];
    } else if (lower.contains('navigate') ||
        lower.contains('hunza') ||
        lower.contains('route') ||
        lower.contains('kkh') ||
        lower.contains('karakoram') ||
        lower.contains('highway')) {
      return _commands[2];
    } else if (lower.contains('fuel') ||
        lower.contains('petrol') ||
        lower.contains('gas') ||
        lower.contains('octane') ||
        lower.contains('pso') ||
        lower.contains('chilas')) {
      return _commands[3];
    }

    // Dynamic custom command
    return _QuickCommand(
      icon: Icons.alt_route_rounded,
      title: '"$query"',
      accentColor: const Color(0xFFF97316),
      badgeBg: const Color(0xFF261911),
      badgeBorder: const Color(0xFF5A2A14),
      responseMessage:
          'Expedition telemetry query received: "$query". Cached map route and emergency mechanics notified.',
    );
  }

  void _processPhrase(String phrase) {
    final cleanPhrase = phrase.trim();
    if (cleanPhrase.isEmpty) return;

    _transitionTo(
      CopilotState.processing,
      feedback: cleanPhrase,
    );

    // Simulated Copilot Processing Delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final lower = cleanPhrase.toLowerCase();

      // Offline mode check: certain cloud features are unavailable when offline
      final bool isOfflineError = _isOfflineMode &&
          (lower.contains('satellite') ||
              lower.contains('live radar') ||
              lower.contains('cloud') ||
              lower.contains('online') ||
              lower.contains('traffic delay'));

      if (isOfflineError) {
        _showErrorModal(
          title: 'OFFLINE CACHE LIMITATION',
          reason:
              'Live satellite radar & online cloud telemetry require an active MESH or cellular connection. Running on local cached expedition data.',
          onRetry: () => _handleMicTap(),
        );
        return;
      }

      // Check for error simulation or unrecognized phrase
      final bool isErrorTrigger = lower.contains('error') ||
          lower.contains('fail') ||
          lower.contains('asdf') ||
          lower.contains('xyz') ||
          lower.contains('disconnect') ||
          lower.contains('unrecognized');

      if (isErrorTrigger) {
        _showErrorModal(
          title: 'COMMAND UNRECOGNIZED',
          reason:
              'Could not match query with expedition telemetry or local waypoint cache. Road/wind noise may have clipped audio, or the command syntax was unrecognized.',
          onRetry: () => _handleMicTap(),
        );
        return;
      }

      final command = _resolveCommandForQuery(cleanPhrase);
      _transitionTo(CopilotState.responding);
      _showResponseModal(command);
    });
  }

  void _transitionTo(CopilotState newState, {String? feedback, String? error}) {
    if (!mounted) return;
    setState(() {
      _state = newState;
      if (feedback != null) _activeCommandFeedback = feedback;
      if (error != null) _errorMessage = error;

      switch (_state) {
        case CopilotState.idle:
          _pulseController.stop();
          _pulseController.value = 0.5;
          _waveController.stop();
          break;
        case CopilotState.listening:
          _errorMessage = '';
          _pulseController.duration = const Duration(milliseconds: 1800);
          _pulseController.repeat(reverse: true);
          _waveController.duration = const Duration(milliseconds: 1200);
          _waveController.repeat();
          break;
        case CopilotState.processing:
          _pulseController.duration = const Duration(milliseconds: 900);
          _pulseController.repeat(reverse: true);
          _waveController.duration = const Duration(milliseconds: 700);
          _waveController.repeat();
          break;
        case CopilotState.responding:
          _pulseController.duration = const Duration(milliseconds: 2200);
          _pulseController.repeat(reverse: true);
          _waveController.duration = const Duration(milliseconds: 1300);
          _waveController.repeat();
          break;
        case CopilotState.error:
          _pulseController.stop();
          _pulseController.value = 0.5;
          _waveController.stop();
          break;
      }
    });
  }

  void _handleMicTap() {
    if (_isListening || _isProcessing) {
      _cancelTranscriptSimulation();
      _transitionTo(CopilotState.idle, feedback: 'Listening paused');
    } else {
      _transitionTo(CopilotState.listening, feedback: '');
      _startLiveTranscriptSimulation();
    }
  }

  void _executeCommand(_QuickCommand command) {
    _cancelTranscriptSimulation();
    setState(() {
      _liveTranscript = command.title.replaceAll('"', '');
    });
    _transitionTo(
      CopilotState.processing,
      feedback: command.title,
    );

    // Simulated Copilot Voice Response
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _transitionTo(CopilotState.responding);
      _showResponseModal(command);
    });
  }

  void _showResponseModal(_QuickCommand command) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF334155), width: 1.5),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: command.badgeBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: command.badgeBorder, width: 1.2),
                    ),
                    child: Icon(command.icon, color: command.accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CAMP COPILOT RESPONSE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          command.title.replaceAll('"', ''),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: Color(0xFFF97316),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        command.responseMessage,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _transitionTo(CopilotState.idle);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Acknowledge Command',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted && _state == CopilotState.responding) {
        _transitionTo(CopilotState.idle);
      }
    });
  }

  /// 4. Error / No-Match Response Modal
  void _showErrorModal({
    required String title,
    required String reason,
    required VoidCallback onRetry,
  }) {
    _transitionTo(
      CopilotState.error,
      error: reason,
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF7F1D1D), width: 1.5),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF991B1B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E1010),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF7F1D1D), width: 1.2),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CAMP COPILOT — UNRECOGNIZED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Color(0xFFF87171),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1313),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF451A1A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFECACA),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _transitionTo(CopilotState.idle);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFCBD5E1),
                        side: const BorderSide(color: Color(0xFF334155), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onRetry();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Retry Command',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted && _state == CopilotState.error) {
        _transitionTo(CopilotState.idle);
      }
    });
  }

  /// 3. Free-Form Text Input Fallback Modal
  void _showTextInputModal() {
    final textController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF334155), width: 1.5),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF261911),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF5A2A14), width: 1.2),
                    ),
                    child: const Icon(
                      Icons.keyboard_alt_outlined,
                      color: Color(0xFFF97316),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FREE-FORM RIDE COMMAND',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Type Copilot Query',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Text Input Field Container
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155), width: 1.2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: textController,
                        autofocus: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Find mechanic, check chain, nearest fuel...',
                          hintStyle: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13.5,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          final val = value.trim();
                          if (val.isNotEmpty) {
                            Navigator.pop(ctx);
                            _cancelTranscriptSimulation();
                            setState(() {
                              _liveTranscript = val;
                            });
                            _processPhrase(val);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Color(0xFFF97316),
                        size: 22,
                      ),
                      onPressed: () {
                        final val = textController.text.trim();
                        if (val.isNotEmpty) {
                          Navigator.pop(ctx);
                          _cancelTranscriptSimulation();
                          setState(() {
                            _liveTranscript = val;
                          });
                          _processPhrase(val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Quick suggestions chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInputChip(
                    label: 'Babusar Mechanics',
                    onTap: () {
                      textController.text = 'Locate mechanics near Babusar Pass';
                    },
                  ),
                  _buildInputChip(
                    label: 'Tire Pressure',
                    onTap: () {
                      textController.text = 'Check tire pressure and chain slack';
                    },
                  ),
                  _buildInputChip(
                    label: 'Nearest Fuel',
                    onTap: () {
                      textController.text = 'How far to next high-octane fuel?';
                    },
                  ),
                  _buildInputChip(
                    label: 'Simulate Error',
                    isErrorChip: true,
                    onTap: () {
                      textController.text = 'Unrecognized audio query error';
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputChip({
    required String label,
    required VoidCallback onTap,
    bool isErrorChip = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isErrorChip ? const Color(0xFF2E1313) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isErrorChip ? const Color(0xFF7F1D1D) : const Color(0xFF334155),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isErrorChip ? const Color(0xFFF87171) : const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D14),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top App Bar (CAMP COPILOT, MESH pill, Keyboard, Close button)
            _buildTopAppBar(),

            // 1.1 Offline Mode Banner
            if (_isOfflineMode) _buildOfflineBanner(),

            // 2. Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 14),

                    // 2.1 Listening Header & Subtitle
                    _buildListeningHeader(),

                    const SizedBox(height: 24),

                    // 2.2 Glowing Microphone with Concentric Sound Rings
                    _buildPulsingMicHub(),

                    // 2.2.1 Cancel/Mute Control Mid-Listening
                    _buildCancelListeningControl(),

                    const SizedBox(height: 18),

                    // 2.3 Live Equalizer Audio Waveform
                    _buildEqualizerWaveform(),

                    const SizedBox(height: 20),

                    // 2.3.1 Live Incremental Transcript Display
                    _buildLiveTranscriptBox(),

                    const SizedBox(height: 24),

                    // 2.4 Quick Rider Commands Section Header
                    _buildCommandsHeader(),

                    const SizedBox(height: 12),

                    // 2.5 Quick Rider Command Cards
                    ..._commands.map((cmd) => Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: _buildCommandCard(cmd),
                        )),

                    const SizedBox(height: 6),

                    // 2.6 Rider Intercom Tip Card
                    _buildTipCard(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 3. Bottom Telemetry Bar (Speed, Idle, Alt)
            _buildBottomTelemetryBar(),
          ],
        ),
      ),
    );
  }

  /// 1. Top App Bar
  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          // Left: Logo badge + "CAMP" + "COPILOT" badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CAMP Square Icon
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'CAMP',
                  style: GoogleFonts.manrope(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // CAMP bold text
              const Text(
                'CAMP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              // COPILOT Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B2314),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF78350F),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'COPILOT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Center-Right: Interactive MESH / OFFLINE Mode Toggle Pill
          GestureDetector(
            onTap: () {
              setState(() {
                _isOfflineMode = !_isOfflineMode;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _isOfflineMode
                    ? const Color(0xFF261908)
                    : const Color(0xFF0F2420),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isOfflineMode
                      ? const Color(0xFF78350F)
                      : const Color(0xFF134E4A),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isOfflineMode
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981),
                      boxShadow: [
                        BoxShadow(
                          color: _isOfflineMode
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isOfflineMode ? 'OFFLINE CACHE' : 'MESH 5.3 ACTIVE',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: _isOfflineMode
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFF5EEAD4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Free-Form Keyboard Fallback Input Button
          GestureDetector(
            onTap: _showTextInputModal,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A222E),
                border: Border.all(
                  color: const Color(0xFF2E3B4E),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.keyboard_alt_outlined,
                color: Color(0xFFCBD5E1),
                size: 19,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Right: Tactile Circular Close Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A222E),
                border: Border.all(
                  color: const Color(0xFF2E3B4E),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Color(0xFFCBD5E1),
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2.1 Listening Header & Subtitle
  Widget _buildListeningHeader() {
    Color dotColor;
    String titleText;
    Color subtitleColor;
    String subtitleText;

    switch (_state) {
      case CopilotState.listening:
        dotColor = const Color(0xFFF97316);
        titleText = 'Listening...';
        subtitleColor = const Color(0xFF7DD3FC);
        subtitleText = _activeCommandFeedback.isNotEmpty
            ? _activeCommandFeedback
            : 'Helmet mic input active — say your ride\ncommand clearly';
        break;
      case CopilotState.processing:
        dotColor = const Color(0xFFFBBF24);
        titleText = 'Processing...';
        subtitleColor = const Color(0xFFFDE68A);
        subtitleText = _activeCommandFeedback.isNotEmpty
            ? 'Analyzing: ${_activeCommandFeedback.replaceAll('"', '')}'
            : 'Analyzing ride query with expedition copilot...';
        break;
      case CopilotState.responding:
        dotColor = const Color(0xFF38BDF8);
        titleText = 'Responding...';
        subtitleColor = const Color(0xFF7DD3FC);
        subtitleText = 'CAMP Copilot voice output active';
        break;
      case CopilotState.error:
        dotColor = const Color(0xFFEF4444);
        titleText = 'Unrecognized';
        subtitleColor = const Color(0xFFFCA5A5);
        subtitleText = _errorMessage.isNotEmpty
            ? _errorMessage
            : 'Command not recognized — tap mic to retry';
        break;
      case CopilotState.idle:
        dotColor = const Color(0xFF64748B);
        titleText = 'Mic Paused';
        subtitleColor = const Color(0xFF94A3B8);
        subtitleText = _activeCommandFeedback.isNotEmpty
            ? _activeCommandFeedback
            : 'Tap mic or say "Hey CAMP" to begin';
        break;
    }

    final bool hasGlow = _state != CopilotState.idle;

    return Column(
      children: [
        // Status dot and Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
                boxShadow: hasGlow
                    ? [
                        BoxShadow(
                          color: dotColor,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              titleText,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitleText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.38,
            fontWeight: FontWeight.w500,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }

  /// 2.2 Glowing Microphone with Concentric Sound Rings
  Widget _buildPulsingMicHub() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final bool isAnimating = _isListening || _isProcessing || _isResponding;
        final scale = isAnimating ? _pulseAnimation.value : 1.0;

        Color ringOuterColor;
        Color ringMidColor;
        Color ringInnerColor;
        List<Color> micGradientColors;
        IconData micIcon;
        Color glowColor;

        switch (_state) {
          case CopilotState.listening:
            ringOuterColor = const Color(0xFF3E2314).withValues(alpha: 0.75);
            ringMidColor = const Color(0xFF6B3113).withValues(alpha: 0.85);
            ringInnerColor = const Color(0xFFEA580C).withValues(alpha: 0.65);
            micGradientColors = const [
              Color(0xFFFFB800),
              Color(0xFFF97316),
              Color(0xFFEA580C),
            ];
            micIcon = Icons.mic_rounded;
            glowColor = const Color(0xFFEA580C);
            break;
          case CopilotState.processing:
            ringOuterColor = const Color(0xFF3D1E08).withValues(alpha: 0.85);
            ringMidColor = const Color(0xFF78350F).withValues(alpha: 0.85);
            ringInnerColor = const Color(0xFFF59E0B).withValues(alpha: 0.7);
            micGradientColors = const [
              Color(0xFFFDE047),
              Color(0xFFF59E0B),
              Color(0xFFD97706),
            ];
            micIcon = Icons.sync_rounded;
            glowColor = const Color(0xFFF59E0B);
            break;
          case CopilotState.responding:
            ringOuterColor = const Color(0xFF082F49).withValues(alpha: 0.75);
            ringMidColor = const Color(0xFF0369A1).withValues(alpha: 0.85);
            ringInnerColor = const Color(0xFF38BDF8).withValues(alpha: 0.65);
            micGradientColors = const [
              Color(0xFF7DD3FC),
              Color(0xFF0284C7),
              Color(0xFF0369A1),
            ];
            micIcon = Icons.volume_up_rounded;
            glowColor = const Color(0xFF0284C7);
            break;
          case CopilotState.error:
            ringOuterColor = const Color(0xFF450A0A).withValues(alpha: 0.7);
            ringMidColor = const Color(0xFF7F1D1D).withValues(alpha: 0.75);
            ringInnerColor = const Color(0xFFEF4444).withValues(alpha: 0.65);
            micGradientColors = const [
              Color(0xFFFCA5A5),
              Color(0xFFEF4444),
              Color(0xFFB91C1C),
            ];
            micIcon = Icons.priority_high_rounded;
            glowColor = const Color(0xFFEF4444);
            break;
          case CopilotState.idle:
            ringOuterColor = const Color(0xFF3E2314).withValues(alpha: 0.25);
            ringMidColor = const Color(0xFF6B3113).withValues(alpha: 0.3);
            ringInnerColor = const Color(0xFFEA580C).withValues(alpha: 0.25);
            micGradientColors = const [
              Color(0xFF475569),
              Color(0xFF334155),
              Color(0xFF1E293B),
            ];
            micIcon = Icons.mic_off_rounded;
            glowColor = Colors.transparent;
            break;
        }

        return SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outermost concentric ring
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 246,
                  height: 246,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ringOuterColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Middle concentric ring
              Transform.scale(
                scale: math.pow(scale, 0.65).toDouble(),
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E130B).withValues(alpha: 0.4),
                    border: Border.all(
                      color: ringMidColor,
                      width: 1.8,
                    ),
                  ),
                ),
              ),

              // Inner glowing concentric ring
              Container(
                width: 138,
                height: 138,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringInnerColor,
                    width: 2.2,
                  ),
                ),
              ),

              // Central Tactile Mic Button
              GestureDetector(
                onTap: _handleMicTap,
                child: Container(
                  width: 106,
                  height: 106,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: micGradientColors,
                    ),
                    boxShadow: [
                      if (glowColor != Colors.transparent)
                        BoxShadow(
                          color: glowColor.withValues(
                            alpha: isAnimating ? 0.55 : 0.25,
                          ),
                          blurRadius: isAnimating ? 34 : 16,
                          spreadRadius: isAnimating ? 5 : 1,
                          offset: const Offset(0, 4),
                        ),
                      BoxShadow(
                        color: micGradientColors.first.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Icon(
                    micIcon,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 2.3 Live Equalizer Audio Waveform
  Widget _buildEqualizerWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final baseHeights = [14.0, 22.0, 32.0, 44.0, 36.0, 44.0, 32.0, 20.0, 14.0];
        final t = _waveController.value * 2 * math.pi;

        List<Color> waveColors;
        switch (_state) {
          case CopilotState.listening:
            waveColors = const [
              Color(0xFFFDE68A),
              Color(0xFFF59E0B),
              Color(0xFFEA580C),
            ];
            break;
          case CopilotState.processing:
            waveColors = const [
              Color(0xFFFEF08A),
              Color(0xFFF59E0B),
              Color(0xFFD97706),
            ];
            break;
          case CopilotState.responding:
            waveColors = const [
              Color(0xFFBAE6FD),
              Color(0xFF38BDF8),
              Color(0xFF0284C7),
            ];
            break;
          case CopilotState.error:
            waveColors = const [
              Color(0xFFFECACA),
              Color(0xFFEF4444),
              Color(0xFF991B1B),
            ];
            break;
          case CopilotState.idle:
            waveColors = const [
              Color(0xFF64748B),
              Color(0xFF475569),
              Color(0xFF334155),
            ];
            break;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(9, (index) {
            double fluctuation = 0;
            if (_isListening) {
              fluctuation = math.sin(t + (index * 0.7)) * 7.0;
            } else if (_isProcessing) {
              fluctuation = math.sin(t * 1.5 + (index * 0.5)) * 4.5;
            } else if (_isResponding) {
              fluctuation = math.sin(t * 1.8 + (index * 0.8)) * 8.0;
            } else {
              // idle or error: resting minimal height
              fluctuation = -baseHeights[index] + 8.0;
            }

            final barHeight = math.max(6.0, baseHeights[index] + fluctuation);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.8),
              width: 5.5,
              height: barHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: waveColors,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  /// 2.3.1 Live Incremental Transcript Display
  Widget _buildLiveTranscriptBox() {
    final hasContent = _liveTranscript.isNotEmpty;

    Color boxBorderColor;
    if (_isListening) {
      boxBorderColor = const Color(0xFFF97316).withValues(alpha: 0.5);
    } else if (_isProcessing) {
      boxBorderColor = const Color(0xFFFBBF24).withValues(alpha: 0.5);
    } else if (_isResponding) {
      boxBorderColor = const Color(0xFF38BDF8).withValues(alpha: 0.5);
    } else if (_isError) {
      boxBorderColor = const Color(0xFFEF4444).withValues(alpha: 0.5);
    } else {
      boxBorderColor = const Color(0xFF1E293B);
    }

    String tagLabel;
    Color tagColor;
    if (_isListening) {
      tagLabel = 'LIVE TRANSCRIPT';
      tagColor = const Color(0xFFF97316);
    } else if (_isProcessing) {
      tagLabel = 'ANALYZING QUERY';
      tagColor = const Color(0xFFFBBF24);
    } else if (_isResponding) {
      tagLabel = 'COMMAND RESOLVED';
      tagColor = const Color(0xFF38BDF8);
    } else if (_isError) {
      tagLabel = 'AUDIO UNRECOGNIZED';
      tagColor = const Color(0xFFEF4444);
    } else {
      tagLabel = 'TRANSCRIPT BUFFER';
      tagColor = const Color(0xFF64748B);
    }

    return GestureDetector(
      onTap: _showTextInputModal,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: boxBorderColor,
            width: 1.2,
          ),
          boxShadow: [
            if (_isListening)
              BoxShadow(
                color: const Color(0xFFF97316).withValues(alpha: 0.1),
                blurRadius: 14,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.graphic_eq_rounded,
                      size: 14,
                      color: tagColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tagLabel,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: tagColor,
                      ),
                    ),
                  ],
                ),
                if (_isStreamingTranscript)
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEF4444),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFEF4444),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'REC',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: const [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 15,
                        color: Color(0xFF64748B),
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Tap to type',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: hasContent
                        ? _liveTranscript
                        : (_isListening
                            ? 'Listening for voice input...'
                            : 'Tap mic or say "Hey CAMP" to begin'),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: hasContent ? FontWeight.w700 : FontWeight.w500,
                      color: hasContent ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                  if (_isStreamingTranscript)
                    const TextSpan(
                      text: ' ▍',
                      style: TextStyle(
                        color: Color(0xFFF97316),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2.4 Quick Commands Section Header
  Widget _buildCommandsHeader() {
    return Row(
      children: [
        const Text(
          'QUICK RIDER COMMANDS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF94A3B8),
          ),
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.bolt_rounded,
              color: Color(0xFFFBBF24),
              size: 15,
            ),
            SizedBox(width: 3),
            Text(
              'Intercom Ready',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFBBF24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 2.5 Individual Command Card
  Widget _buildCommandCard(_QuickCommand command) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _executeCommand(command),
        borderRadius: BorderRadius.circular(16),
        splashColor: command.accentColor.withValues(alpha: 0.15),
        highlightColor: command.accentColor.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12.5),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1E293B),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: command.badgeBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: command.badgeBorder,
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  command.icon,
                  color: command.accentColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 14),
              // Command Text
              Expanded(
                child: Text(
                  command.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              // Chevron Trailing
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF475569),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2.6 Rider Intercom Tip Card
  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1526),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF1E293B),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1.0),
            child: Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFFBBF24),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  height: 1.4,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
                children: const [
                  TextSpan(text: 'Tip: Say '),
                  TextSpan(
                    text: '"Hey CAMP"',
                    style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: ' anytime or double–tap your helmet intercom button.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2.2.1 Cancel / Mute Intercom mid-listening
  Widget _buildCancelListeningControl() {
    if (_isIdle || _isError) {
      return const SizedBox(height: 12);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 14.0),
      child: GestureDetector(
        onTap: () {
          _cancelTranscriptSimulation();
          _transitionTo(CopilotState.idle, feedback: 'Listening cancelled');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7.5),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1313),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF7F1D1D).withValues(alpha: 0.8),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.stop_circle_outlined,
                color: Color(0xFFEF4444),
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Cancel / Mute Intercom',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFCA5A5),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 1.1 Offline Expedition Banner
  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 2, 18, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1307),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF78350F),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2E1C0A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF92400E), width: 1),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFF59E0B),
              size: 17,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'OFFLINE EXPEDITION MODE ACTIVE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Running on local waypoint cache (Pak-Northern Areas). Cloud voice synthesis paused.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFDE68A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isOfflineMode = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF2E1C0A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF92400E)),
              ),
              child: const Text(
                'RECONNECT',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFBBF24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Bottom Telemetry Bar (Speed, Idle, Alt)
  Widget _buildBottomTelemetryBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF090D14),
        border: Border(
          top: BorderSide(
            color: Color(0xFF1E293B),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left: Speed + Idle Indicator
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF10B981),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF10B981),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'Speed: ',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const Text(
                '0 km/h',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Text(
                ' • ',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Idle',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Right: Altitude Metric
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.north_east_rounded,
                color: Color(0xFF64748B),
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                'Alt: ',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Text(
                '2,410m',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickCommand {
  final IconData icon;
  final String title;
  final Color accentColor;
  final Color badgeBg;
  final Color badgeBorder;
  final String responseMessage;

  const _QuickCommand({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.badgeBg,
    required this.badgeBorder,
    required this.responseMessage,
  });
}
