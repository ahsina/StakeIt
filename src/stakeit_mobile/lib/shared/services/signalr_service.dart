import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import './storage_service.dart';

// Provider for SignalR service
final signalRServiceProvider = Provider<SignalRService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SignalRService(storage);
});

class SignalRService {
  final StorageService _storage;
  HubConnection? _hubConnection;
  bool _isConnected = false;

  // Stream controllers for real-time events
  final _messageController = StreamController<ChallengeMessageEvent>.broadcast();
  final _proofSubmittedController = StreamController<ProofSubmittedEvent>.broadcast();
  final _leaderboardUpdatedController = StreamController<LeaderboardUpdatedEvent>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  // Public streams
  Stream<ChallengeMessageEvent> get onMessageReceived => _messageController.stream;
  Stream<ProofSubmittedEvent> get onProofSubmitted => _proofSubmittedController.stream;
  Stream<LeaderboardUpdatedEvent> get onLeaderboardUpdated => _leaderboardUpdatedController.stream;
  Stream<bool> get onConnectionStatusChanged => _connectionStatusController.stream;

  bool get isConnected => _isConnected;

  SignalRService(this._storage);

  /// Initialize and connect to SignalR hub
  Future<void> connect() async {
    if (_isConnected) {
      return;
    }

    try {
      final token = await _storage.getAccessToken();
      if (token == null) {
        throw Exception('No access token available');
      }

      // Create hub connection
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            AppConfig.challengeHubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              transport: HttpTransportType.WebSockets,
              skipNegotiation: true,
              logging: (level, message) {
                print('SignalR [$level]: $message');
              },
            ),
          )
          .withAutomaticReconnect()
          .build();

      // Register event handlers
      _registerEventHandlers();

      // Handle reconnecting
      _hubConnection?.onreconnecting((error) {
        print('SignalR reconnecting: $error');
        _isConnected = false;
        _connectionStatusController.add(false);
      });

      // Handle reconnected
      _hubConnection?.onreconnected((connectionId) {
        print('SignalR reconnected: $connectionId');
        _isConnected = true;
        _connectionStatusController.add(true);
      });

      // Handle close
      _hubConnection?.onclose((error) {
        print('SignalR connection closed: $error');
        _isConnected = false;
        _connectionStatusController.add(false);
      });

      // Start connection
      await _hubConnection?.start();
      _isConnected = true;
      _connectionStatusController.add(true);
      print('SignalR connected successfully');
    } catch (e) {
      print('SignalR connection error: $e');
      _isConnected = false;
      _connectionStatusController.add(false);
      rethrow;
    }
  }

  /// Disconnect from SignalR hub
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection?.stop();
      _isConnected = false;
      _connectionStatusController.add(false);
    }
  }

  /// Register event handlers for SignalR events
  void _registerEventHandlers() {
    // New message received
    _hubConnection?.on('NewMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        final event = ChallengeMessageEvent.fromJson(data);
        _messageController.add(event);
      }
    });

    // Proof submitted
    _hubConnection?.on('ProofSubmitted', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        final event = ProofSubmittedEvent.fromJson(data);
        _proofSubmittedController.add(event);
      }
    });

    // Leaderboard updated
    _hubConnection?.on('LeaderboardUpdated', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        final event = LeaderboardUpdatedEvent.fromJson(data);
        _leaderboardUpdatedController.add(event);
      }
    });
  }

  /// Join a challenge room
  Future<void> joinChallenge(int challengeId) async {
    if (!_isConnected) {
      await connect();
    }

    try {
      await _hubConnection?.invoke('JoinChallenge', args: [challengeId]);
      print('Joined challenge $challengeId');
    } catch (e) {
      print('Error joining challenge: $e');
      rethrow;
    }
  }

  /// Leave a challenge room
  Future<void> leaveChallenge(int challengeId) async {
    if (!_isConnected) {
      return;
    }

    try {
      await _hubConnection?.invoke('LeaveChallenge', args: [challengeId]);
      print('Left challenge $challengeId');
    } catch (e) {
      print('Error leaving challenge: $e');
    }
  }

  /// Send a message to a challenge
  Future<void> sendMessage(int challengeId, String message) async {
    if (!_isConnected) {
      await connect();
    }

    try {
      await _hubConnection?.invoke('SendMessage', args: [challengeId, message]);
      print('Message sent to challenge $challengeId');
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _messageController.close();
    _proofSubmittedController.close();
    _leaderboardUpdatedController.close();
    _connectionStatusController.close();
    disconnect();
  }
}

// Event models
class ChallengeMessageEvent {
  final int challengeId;
  final int messageId;
  final int userId;
  final String userName;
  final String message;
  final DateTime timestamp;

  ChallengeMessageEvent({
    required this.challengeId,
    required this.messageId,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
  });

  factory ChallengeMessageEvent.fromJson(Map<String, dynamic> json) {
    return ChallengeMessageEvent(
      challengeId: json['challengeId'] as int,
      messageId: json['messageId'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class ProofSubmittedEvent {
  final int challengeId;
  final int participantId;
  final String userName;
  final int newCount;

  ProofSubmittedEvent({
    required this.challengeId,
    required this.participantId,
    required this.userName,
    required this.newCount,
  });

  factory ProofSubmittedEvent.fromJson(Map<String, dynamic> json) {
    return ProofSubmittedEvent(
      challengeId: json['challengeId'] as int,
      participantId: json['participantId'] as int,
      userName: json['userName'] as String,
      newCount: json['newCount'] as int,
    );
  }
}

class LeaderboardUpdatedEvent {
  final int challengeId;
  final List<LeaderboardEntry> entries;

  LeaderboardUpdatedEvent({
    required this.challengeId,
    required this.entries,
  });

  factory LeaderboardUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return LeaderboardUpdatedEvent(
      challengeId: json['challengeId'] as int,
      entries: (json['entries'] as List)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final int userId;
  final String userName;
  final int currentCount;
  final bool isCompleted;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.currentCount,
    required this.isCompleted,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      currentCount: json['currentCount'] as int,
      isCompleted: json['isCompleted'] as bool,
    );
  }
}
