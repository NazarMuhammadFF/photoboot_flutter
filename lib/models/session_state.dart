import 'grid_config.dart';
import 'template_config.dart';

enum SessionStatus {
  idle,
  gridSelection,
  templateSelection,
  capturing,
  editing,
  reviewing,
  printing,
  completed,
}

class SessionState {
  final String id;
  final SessionStatus status;
  final GridConfig? selectedGrid;
  final TemplateConfig? selectedTemplate;
  final int currentSlotIndex;
  final List<String> capturedPhotos;
  final DateTime startedAt;
  final DateTime? completedAt;

  SessionState({
    required this.id,
    this.status = SessionStatus.idle,
    this.selectedGrid,
    this.selectedTemplate,
    this.currentSlotIndex = 0,
    this.capturedPhotos = const [],
    DateTime? startedAt,
    this.completedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  int get totalSlots => selectedGrid?.slots.length ?? 0;
  int get photosTaken => capturedPhotos.length;
  bool get isComplete => photosTaken >= totalSlots && totalSlots > 0;
  double get progress => totalSlots > 0 ? photosTaken / totalSlots : 0;

  SessionState copyWith({
    String? id,
    SessionStatus? status,
    GridConfig? selectedGrid,
    TemplateConfig? selectedTemplate,
    int? currentSlotIndex,
    List<String>? capturedPhotos,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return SessionState(
      id: id ?? this.id,
      status: status ?? this.status,
      selectedGrid: selectedGrid ?? this.selectedGrid,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      currentSlotIndex: currentSlotIndex ?? this.currentSlotIndex,
      capturedPhotos: capturedPhotos ?? this.capturedPhotos,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'grid_id': selectedGrid?.id,
      'template_id': selectedTemplate?.id,
      'current_slot_index': currentSlotIndex,
      'captured_photos': capturedPhotos,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

class PrintRequest {
  final String id;
  final String sessionId;
  final String previewPath;
  final DateTime requestedAt;
  final PrintRequestStatus status;

  PrintRequest({
    required this.id,
    required this.sessionId,
    required this.previewPath,
    DateTime? requestedAt,
    this.status = PrintRequestStatus.pending,
  }) : requestedAt = requestedAt ?? DateTime.now();

  PrintRequest copyWith({
    String? id,
    String? sessionId,
    String? previewPath,
    DateTime? requestedAt,
    PrintRequestStatus? status,
  }) {
    return PrintRequest(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      previewPath: previewPath ?? this.previewPath,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
    );
  }
}

enum PrintRequestStatus {
  pending,
  approved,
  rejected,
  printing,
  completed,
  failed,
}
