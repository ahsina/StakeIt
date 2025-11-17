import 'package:freezed_annotation/freezed_annotation.dart';

part 'asymmetric_bet_model.freezed.dart';
part 'asymmetric_bet_model.g.dart';

// Asymmetric Duel - Person A bets that Person B will fail at their stake
// If B succeeds, B wins A's money. If B fails, A keeps money and B loses their stake.

@freezed
class AsymmetricBetModel with _$AsymmetricBetModel {
  const factory AsymmetricBetModel({
    required int id,
    required int bettorId, // Person A who bets against
    required String bettorName,
    required int targetId, // Person B who is being bet against
    required String targetName,
    required int targetStakeId, // The stake that B is attempting
    required double betAmount, // How much A is risking
    required double odds, // Multiplier if B succeeds (e.g., 2.5x)
    required DateTime createdAt,
    required DateTime expiresAt,
    required BetStatus status,
    DateTime? settledAt,
    String? outcome, // 'bettor_wins', 'target_wins'
  }) = _AsymmetricBetModel;

  factory AsymmetricBetModel.fromJson(Map<String, dynamic> json) =>
      _$AsymmetricBetModelFromJson(json);
}

enum BetStatus {
  @JsonValue('Pending')
  pending,
  @JsonValue('Accepted')
  accepted,
  @JsonValue('Rejected')
  rejected,
  @JsonValue('Active')
  active,
  @JsonValue('Settled')
  settled,
  @JsonValue('Cancelled')
  cancelled,
}

extension AsymmetricBetModelX on AsymmetricBetModel {
  double get potentialWinning => betAmount * odds;

  bool get isActive => status == BetStatus.active;
  bool get isPending => status == BetStatus.pending;
  bool get isSettled => status == BetStatus.settled;
}
