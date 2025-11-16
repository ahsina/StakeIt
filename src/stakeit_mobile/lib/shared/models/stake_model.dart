import 'package:freezed_annotation/freezed_annotation.dart';

part 'stake_model.freezed.dart';
part 'stake_model.g.dart';

enum StakeStatus {
  @JsonValue('Pending')
  pending,
  @JsonValue('Active')
  active,
  @JsonValue('Completed')
  completed,
  @JsonValue('Failed')
  failed,
  @JsonValue('Cancelled')
  cancelled,
}

enum StakeCategory {
  @JsonValue('Fitness')
  fitness,
  @JsonValue('Education')
  education,
  @JsonValue('Productivity')
  productivity,
  @JsonValue('Finance')
  finance,
  @JsonValue('PersonalDevelopment')
  personalDevelopment,
  @JsonValue('Family')
  family,
  @JsonValue('Creativity')
  creativity,
  @JsonValue('Home')
  home,
  @JsonValue('DigitalDetox')
  digitalDetox,
}

enum ProofMode {
  @JsonValue('GPS')
  gps,
  @JsonValue('Photo')
  photo,
  @JsonValue('Manual')
  manual,
}

enum FailureMode {
  @JsonValue('AllOrNothing')
  allOrNothing,
  @JsonValue('ProRata')
  proRata,
  @JsonValue('Progressive')
  progressive,
}

enum StakeFrequency {
  @JsonValue('Daily')
  daily,
  @JsonValue('Weekly')
  weekly,
  @JsonValue('Custom')
  custom,
}

@freezed
class StakeModel with _$StakeModel {
  const factory StakeModel({
    required int id,
    required int userId,
    required String title,
    String? description,
    required StakeCategory category,
    required double amountEUR,
    required StakeStatus status,
    required int requiredCount,
    required int currentCount,
    required ProofMode proofMode,
    required FailureMode failureMode,
    @Default(StakeFrequency.custom) StakeFrequency frequency,
    int? geofenceId,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? completedAt,
    DateTime? settledAt,
    required DateTime createdAt,
  }) = _StakeModel;

  factory StakeModel.fromJson(Map<String, dynamic> json) =>
      _$StakeModelFromJson(json);
}

const StakeModel._(); // For adding computed properties

extension StakeModelX on StakeModel {
  double get progressPercentage =>
      requiredCount > 0 ? (currentCount / requiredCount * 100) : 0;

  Duration get timeRemaining => endDate.difference(DateTime.now());

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isActive => status == StakeStatus.active;

  bool get canCancel {
    final hoursSinceCreation = DateTime.now().difference(createdAt).inHours;
    return hoursSinceCreation < 2 && status == StakeStatus.pending;
  }

  Duration get cancellationTimeRemaining {
    final twoHoursFromCreation = createdAt.add(const Duration(hours: 2));
    return twoHoursFromCreation.difference(DateTime.now());
  }

  String get categoryName {
    switch (category) {
      case StakeCategory.fitness:
        return 'Fitness';
      case StakeCategory.education:
        return 'Éducation';
      case StakeCategory.productivity:
        return 'Productivité';
      case StakeCategory.finance:
        return 'Finance';
      case StakeCategory.personalDevelopment:
        return 'Développement Personnel';
      case StakeCategory.family:
        return 'Famille';
      case StakeCategory.creativity:
        return 'Créativité';
      case StakeCategory.home:
        return 'Maison';
      case StakeCategory.digitalDetox:
        return 'Détox Numérique';
    }
  }

  String get frequencyName {
    switch (frequency) {
      case StakeFrequency.daily:
        return 'Quotidien';
      case StakeFrequency.weekly:
        return 'Hebdomadaire';
      case StakeFrequency.custom:
        return 'Personnalisé';
    }
  }
}

@freezed
class CreateStakeRequest with _$CreateStakeRequest {
  const factory CreateStakeRequest({
    required String title,
    String? description,
    required StakeCategory category,
    required double amountEUR,
    required DateTime endDate,
    required int requiredCount,
    required ProofMode proofMode,
    required FailureMode failureMode,
    @Default(StakeFrequency.custom) StakeFrequency frequency,
    int? geofenceId,
  }) = _CreateStakeRequest;

  factory CreateStakeRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateStakeRequestFromJson(json);
}

@freezed
class StakeProofModel with _$StakeProofModel {
  const factory StakeProofModel({
    required int id,
    required int stakeId,
    double? latitude,
    double? longitude,
    String? photoUrl,
    String? notes,
    required String validationStatus,
    String? rejectionReason,
    required DateTime submittedAt,
    DateTime? validatedAt,
  }) = _StakeProofModel;

  factory StakeProofModel.fromJson(Map<String, dynamic> json) =>
      _$StakeProofModelFromJson(json);
}

@freezed
class SubmitProofRequest with _$SubmitProofRequest {
  const factory SubmitProofRequest({
    double? latitude,
    double? longitude,
    String? photoUrl,
    String? notes,
  }) = _SubmitProofRequest;

  factory SubmitProofRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitProofRequestFromJson(json);
}
