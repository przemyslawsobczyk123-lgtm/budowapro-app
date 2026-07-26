import 'package:budowapro/features/captures/domain/capture_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptureDraftInput', () {
    test('derives missing context for every quick capture type', () {
      expect(
        CaptureDraftInput(
          projectId: 'project-1',
          type: CaptureDraftType.photo,
        ).missingContext,
        <CaptureMissingContext>{
          CaptureMissingContext.title,
          CaptureMissingContext.attachment,
        },
      );
      expect(
        CaptureDraftInput(
          projectId: 'project-1',
          type: CaptureDraftType.note,
        ).missingContext,
        <CaptureMissingContext>{
          CaptureMissingContext.title,
          CaptureMissingContext.content,
        },
      );
      expect(
        CaptureDraftInput(
          projectId: 'project-1',
          type: CaptureDraftType.cost,
        ).missingContext,
        <CaptureMissingContext>{
          CaptureMissingContext.title,
          CaptureMissingContext.grossAmount,
          CaptureMissingContext.vatRate,
        },
      );
      expect(
        CaptureDraftInput(
          projectId: 'project-1',
          type: CaptureDraftType.task,
        ).missingContext,
        <CaptureMissingContext>{
          CaptureMissingContext.title,
          CaptureMissingContext.scheduledAt,
        },
      );
    });

    test('becomes ready only when required context is complete', () {
      final cost = CaptureDraftInput(
        projectId: 'project-1',
        type: CaptureDraftType.cost,
        title: 'Beton',
        grossAmountMinorUnits: 12345,
        vatRateBasisPoints: 2300,
      );
      final task = CaptureDraftInput(
        projectId: 'project-1',
        type: CaptureDraftType.task,
        title: 'Odbierz dostawę',
        scheduledAt: DateTime.utc(2026, 8, 1, 8),
        timeZoneId: 'Europe/Warsaw',
      );
      final voice = CaptureDraftInput(
        projectId: 'project-1',
        type: CaptureDraftType.voice,
        title: 'Ustalenia z elektrykiem',
        attachmentIds: const <String>['audio-1'],
      );

      expect(cost.status, CaptureDraftStatus.ready);
      expect(task.status, CaptureDraftStatus.ready);
      expect(voice.status, CaptureDraftStatus.ready);
    });

    test('normalizes text, attachments and optional financial context', () {
      final input = CaptureDraftInput(
        projectId: ' project-1 ',
        type: CaptureDraftType.document,
        title: ' Projekt instalacji ',
        content: ' Do sprawdzenia ',
        attachmentIds: const <String>[' file-1 ', 'file-1', 'file-2'],
      );

      expect(input.projectId, 'project-1');
      expect(input.title, 'Projekt instalacji');
      expect(input.content, 'Do sprawdzenia');
      expect(input.attachmentIds, <String>['file-1', 'file-2']);
      expect(
        () => CaptureDraftInput(
          projectId: 'project-1',
          type: CaptureDraftType.cost,
          grossAmountMinorUnits: 100,
          vatRateBasisPoints: 500,
        ),
        throwsArgumentError,
      );
    });
  });

  test('classified capture requires a matching target reference', () {
    final input = CaptureDraftInput(
      projectId: 'project-1',
      type: CaptureDraftType.note,
      title: 'Zmiana układu',
      content: 'Przesunąć gniazdo.',
    );

    expect(
      () => CaptureDraft(
        id: 'capture-1',
        input: input,
        status: CaptureDraftStatus.classified,
        createdAt: DateTime.utc(2026, 7, 26),
        updatedAt: DateTime.utc(2026, 7, 26),
      ),
      throwsArgumentError,
    );
    final classified = CaptureDraft(
      id: 'capture-1',
      input: input,
      status: CaptureDraftStatus.classified,
      targetType: CaptureTargetType.note,
      targetId: 'capture-1',
      createdAt: DateTime.utc(2026, 7, 26),
      updatedAt: DateTime.utc(2026, 7, 26),
    );

    expect(classified.isOpen, isFalse);
    expect(classified.canClassify, isFalse);
  });
}
