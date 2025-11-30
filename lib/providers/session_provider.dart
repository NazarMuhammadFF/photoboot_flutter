import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/session_state.dart';
import '../models/grid_config.dart';
import '../models/template_config.dart';

class SessionProvider with ChangeNotifier {
  SessionState? _currentSession;
  final List<PrintRequest> _printQueue = [];

  SessionState? get currentSession => _currentSession;
  List<PrintRequest> get printQueue => List.unmodifiable(_printQueue);
  List<PrintRequest> get pendingPrints =>
      _printQueue.where((p) => p.status == PrintRequestStatus.pending).toList();

  bool get hasActiveSession =>
      _currentSession != null &&
      _currentSession!.status != SessionStatus.idle &&
      _currentSession!.status != SessionStatus.completed;

  void startSession() {
    _currentSession = SessionState(
      id: const Uuid().v4(),
      status: SessionStatus.gridSelection,
    );
    notifyListeners();
  }

  void selectGrid(GridConfig grid) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        selectedGrid: grid,
        status: SessionStatus.templateSelection,
      );
      notifyListeners();
    }
  }

  void selectTemplate(TemplateConfig template) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        selectedTemplate: template,
        status: SessionStatus.capturing,
      );
      notifyListeners();
    }
  }

  void skipTemplateSelection() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.capturing,
      );
      notifyListeners();
    }
  }

  void addCapturedPhoto(String photoPath) {
    if (_currentSession != null) {
      final newPhotos = List<String>.from(_currentSession!.capturedPhotos)
        ..add(photoPath);

      final newIndex = _currentSession!.currentSlotIndex + 1;
      final isComplete = newPhotos.length >= _currentSession!.totalSlots;

      _currentSession = _currentSession!.copyWith(
        capturedPhotos: newPhotos,
        currentSlotIndex: newIndex,
        status: isComplete ? SessionStatus.editing : SessionStatus.capturing,
      );
      notifyListeners();
    }
  }

  void retakePhoto(int slotIndex) {
    if (_currentSession != null &&
        slotIndex < _currentSession!.capturedPhotos.length) {
      final newPhotos = List<String>.from(_currentSession!.capturedPhotos);
      newPhotos.removeAt(slotIndex);

      _currentSession = _currentSession!.copyWith(
        capturedPhotos: newPhotos,
        currentSlotIndex: slotIndex,
        status: SessionStatus.capturing,
      );
      notifyListeners();
    }
  }

  void moveToReview() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.reviewing,
      );
      notifyListeners();
    }
  }

  void requestPrint(String previewPath) {
    if (_currentSession != null) {
      final request = PrintRequest(
        id: const Uuid().v4(),
        sessionId: _currentSession!.id,
        previewPath: previewPath,
      );
      _printQueue.add(request);

      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.printing,
      );
      notifyListeners();
    }
  }

  void approvePrint(String requestId) {
    final index = _printQueue.indexWhere((p) => p.id == requestId);
    if (index != -1) {
      _printQueue[index] = _printQueue[index].copyWith(
        status: PrintRequestStatus.approved,
      );
      notifyListeners();
    }
  }

  void rejectPrint(String requestId) {
    final index = _printQueue.indexWhere((p) => p.id == requestId);
    if (index != -1) {
      _printQueue[index] = _printQueue[index].copyWith(
        status: PrintRequestStatus.rejected,
      );
      notifyListeners();
    }
  }

  void completePrint(String requestId) {
    final index = _printQueue.indexWhere((p) => p.id == requestId);
    if (index != -1) {
      _printQueue[index] = _printQueue[index].copyWith(
        status: PrintRequestStatus.completed,
      );
    }

    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.completed,
        completedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  void completeSession() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.completed,
        completedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void resetSession() {
    _currentSession = null;
    notifyListeners();
  }

  void forceEndSession() {
    _currentSession = null;
    notifyListeners();
  }

  void clearCompletedPrints() {
    _printQueue.removeWhere(
      (p) =>
          p.status == PrintRequestStatus.completed ||
          p.status == PrintRequestStatus.rejected,
    );
    notifyListeners();
  }
}
