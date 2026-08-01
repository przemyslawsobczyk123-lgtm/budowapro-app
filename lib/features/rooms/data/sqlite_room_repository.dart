import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:budowapro/features/rooms/domain/room_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:sqflite/sqflite.dart';

final class SqliteRoomRepository implements RoomRepository {
  SqliteRoomRepository({
    required this._database,
    required this._idGenerator,
    required this._utcNow,
  });

  final AppDatabase _database;
  final String Function() _idGenerator;
  final DateTime Function() _utcNow;

  @override
  Future<Page<RoomOverview>> listRooms(
    RoomQuery query,
    PageRequest request,
  ) async {
    final database = await _database.open();
    final filter = _roomFilter(query);
    final countRows = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM ${AppDatabase.roomsTable} r '
      'WHERE ${filter.sql}',
      filter.arguments,
    );
    final rows = await database.rawQuery(
      '$_roomOverviewSelect WHERE ${filter.sql} '
      'ORDER BY r.floor_label COLLATE NOCASE ASC, '
      'r.name COLLATE NOCASE ASC, r.id ASC LIMIT ? OFFSET ?',
      <Object?>[...filter.arguments, request.limit, request.offset],
    );
    return Page<RoomOverview>(
      items: rows.map(_overviewFromRow),
      totalCount: countRows.single['total']! as int,
      request: request,
    );
  }

  @override
  Future<Room?> findRoom({
    required String projectId,
    required String roomId,
  }) async {
    final database = await _database.open();
    return _findRoom(database, projectId: projectId, roomId: roomId);
  }

  @override
  Future<RoomDetails?> findRoomDetails({
    required String projectId,
    required String roomId,
  }) async {
    final database = await _database.open();
    final rows = await database.rawQuery(
      '$_roomOverviewSelect WHERE r.project_id = ? AND r.id = ? LIMIT 1',
      <Object?>[projectId, roomId],
    );
    if (rows.isEmpty) return null;
    final choices = await _listChoices(
      database,
      projectId: projectId,
      roomId: roomId,
    );
    final contactRows = await database.query(
      AppDatabase.roomContactLinksTable,
      columns: const <String>['contact_id'],
      where: 'project_id = ? AND room_id = ?',
      whereArgs: <Object?>[projectId, roomId],
      orderBy: 'contact_id ASC',
    );
    return RoomDetails(
      overview: _overviewFromRow(rows.single),
      choices: choices,
      contactIds: contactRows.map((row) => row['contact_id']! as String),
    );
  }

  @override
  Future<Room> createRoom(RoomInput input) {
    return _database.transaction<Room>((transaction) async {
      await _validateProjectAndCurrency(transaction, input);
      final now = _utcNow().toUtc();
      final room = Room(
        id: _idGenerator(),
        input: input,
        createdAt: now,
        updatedAt: now,
      );
      try {
        await transaction.insert(AppDatabase.roomsTable, _roomToRow(room));
      } on DatabaseException {
        throw const RoomConflictException();
      }
      return room;
    });
  }

  @override
  Future<Room> updateRoom({
    required String projectId,
    required String roomId,
    required RoomInput input,
  }) {
    return _database.transaction<Room>((transaction) async {
      if (projectId != input.projectId) {
        throw ArgumentError.value(input.projectId, 'input.projectId');
      }
      final existing = await _requiredRoom(
        transaction,
        projectId: projectId,
        roomId: roomId,
      );
      await _validateProjectAndCurrency(transaction, input);
      final updated = Room(
        id: roomId,
        input: input,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
      );
      try {
        await transaction.update(
          AppDatabase.roomsTable,
          _roomToRow(updated),
          where: 'project_id = ? AND id = ?',
          whereArgs: <Object?>[projectId, roomId],
        );
      } on DatabaseException {
        throw const RoomConflictException();
      }
      return updated;
    });
  }

  @override
  Future<void> deleteRoom({required String projectId, required String roomId}) {
    return _database.transaction<void>((transaction) async {
      final count = await transaction.delete(
        AppDatabase.roomsTable,
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, roomId],
      );
      if (count == 0) throw const RoomNotFoundException();
    });
  }

  @override
  Future<RoomChoice> createChoice({
    required RoomChoiceInput input,
    required Iterable<RoomChoiceVariantInput> variants,
  }) {
    return _database.transaction<RoomChoice>((transaction) async {
      final normalizedVariants = boundedVariants(variants);
      await _validateChoiceInput(transaction, input, normalizedVariants);
      final now = _utcNow().toUtc();
      final choiceId = _idGenerator();
      await transaction.insert(
        AppDatabase.roomChoicesTable,
        _choiceInputToRow(
          id: choiceId,
          input: input,
          status: RoomChoiceStatus.open,
          createdAt: now,
          updatedAt: now,
        ),
      );
      for (final variant in normalizedVariants) {
        await transaction.insert(
          AppDatabase.roomChoiceVariantsTable,
          _variantInputToRow(
            id: _idGenerator(),
            choiceId: choiceId,
            input: variant,
            isSelected: false,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      return _requiredChoice(transaction, input.projectId, choiceId);
    });
  }

  @override
  Future<RoomChoice> updateChoice({
    required String projectId,
    required String choiceId,
    required RoomChoiceInput input,
    required Iterable<RoomChoiceVariantInput> variants,
  }) {
    return _database.transaction<RoomChoice>((transaction) async {
      if (projectId != input.projectId) {
        throw ArgumentError.value(input.projectId, 'input.projectId');
      }
      final normalizedVariants = boundedVariants(variants);
      final existing = await _requiredChoice(transaction, projectId, choiceId);
      await _validateChoiceInput(transaction, input, normalizedVariants);
      final now = _utcNow().toUtc();
      await transaction.update(
        AppDatabase.roomChoicesTable,
        _choiceInputToRow(
          id: choiceId,
          input: input,
          status: RoomChoiceStatus.open,
          createdAt: existing.createdAtUtc,
          updatedAt: now,
        ),
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, choiceId],
      );
      await transaction.delete(
        AppDatabase.roomChoiceVariantsTable,
        where: 'project_id = ? AND choice_id = ?',
        whereArgs: <Object?>[projectId, choiceId],
      );
      for (final variant in normalizedVariants) {
        await transaction.insert(
          AppDatabase.roomChoiceVariantsTable,
          _variantInputToRow(
            id: _idGenerator(),
            choiceId: choiceId,
            input: variant,
            isSelected: false,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      return _requiredChoice(transaction, projectId, choiceId);
    });
  }

  @override
  Future<RoomChoice> selectVariant({
    required String projectId,
    required String choiceId,
    required String variantId,
  }) {
    return _setChoiceStatus(
      projectId: projectId,
      choiceId: choiceId,
      status: RoomChoiceStatus.selected,
      selectedVariantId: variantId,
    );
  }

  @override
  Future<RoomChoice> reopenChoice({
    required String projectId,
    required String choiceId,
  }) {
    return _setChoiceStatus(
      projectId: projectId,
      choiceId: choiceId,
      status: RoomChoiceStatus.open,
    );
  }

  @override
  Future<RoomChoice> cancelChoice({
    required String projectId,
    required String choiceId,
  }) {
    return _setChoiceStatus(
      projectId: projectId,
      choiceId: choiceId,
      status: RoomChoiceStatus.cancelled,
    );
  }

  @override
  Future<void> deleteChoice({
    required String projectId,
    required String choiceId,
  }) {
    return _database.transaction<void>((transaction) async {
      final count = await transaction.delete(
        AppDatabase.roomChoicesTable,
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, choiceId],
      );
      if (count == 0) throw const RoomChoiceNotFoundException();
    });
  }

  Future<RoomChoice> _setChoiceStatus({
    required String projectId,
    required String choiceId,
    required RoomChoiceStatus status,
    String? selectedVariantId,
  }) {
    return _database.transaction<RoomChoice>((transaction) async {
      await _requiredChoice(transaction, projectId, choiceId);
      await transaction.update(
        AppDatabase.roomChoiceVariantsTable,
        const <String, Object?>{'is_selected': 0},
        where: 'project_id = ? AND choice_id = ?',
        whereArgs: <Object?>[projectId, choiceId],
      );
      if (status == RoomChoiceStatus.selected) {
        final updated = await transaction.update(
          AppDatabase.roomChoiceVariantsTable,
          const <String, Object?>{'is_selected': 1},
          where: 'project_id = ? AND choice_id = ? AND id = ?',
          whereArgs: <Object?>[projectId, choiceId, selectedVariantId],
        );
        if (updated == 0) throw const RoomVariantNotFoundException();
      }
      await transaction.update(
        AppDatabase.roomChoicesTable,
        <String, Object?>{
          'status': status.name,
          'updated_at_utc_ms': _milliseconds(_utcNow()),
        },
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, choiceId],
      );
      return _requiredChoice(transaction, projectId, choiceId);
    });
  }

  @override
  Future<void> assignRecord({
    required String projectId,
    required String roomId,
    required RoomRecordType type,
    required String recordId,
  }) {
    return _database.transaction<void>((transaction) async {
      await _requiredRoom(transaction, projectId: projectId, roomId: roomId);
      if (!await _recordExists(
        transaction,
        projectId: projectId,
        type: type,
        recordId: recordId,
      )) {
        throw const RoomRelationNotFoundException();
      }
      await transaction.insert(
        AppDatabase.roomRecordLinksTable,
        <String, Object?>{
          'project_id': projectId,
          'room_id': roomId,
          'record_type': _recordTypeToStorage(type),
          'record_id': recordId,
          'linked_at_utc_ms': _milliseconds(_utcNow()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  @override
  Future<void> unassignRecord({
    required String projectId,
    required RoomRecordType type,
    required String recordId,
  }) async {
    final database = await _database.open();
    await database.delete(
      AppDatabase.roomRecordLinksTable,
      where: 'project_id = ? AND record_type = ? AND record_id = ?',
      whereArgs: <Object?>[projectId, _recordTypeToStorage(type), recordId],
    );
  }

  @override
  Future<void> setContactLinked({
    required String projectId,
    required String roomId,
    required String contactId,
    required bool isLinked,
  }) {
    return _database.transaction<void>((transaction) async {
      await _requiredRoom(transaction, projectId: projectId, roomId: roomId);
      if (!isLinked) {
        await transaction.delete(
          AppDatabase.roomContactLinksTable,
          where: 'project_id = ? AND room_id = ? AND contact_id = ?',
          whereArgs: <Object?>[projectId, roomId, contactId],
        );
        return;
      }
      final contact = await transaction.query(
        AppDatabase.contactsTable,
        columns: const <String>['id'],
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, contactId],
        limit: 1,
      );
      if (contact.isEmpty) throw const RoomRelationNotFoundException();
      await transaction.insert(
        AppDatabase.roomContactLinksTable,
        <String, Object?>{
          'project_id': projectId,
          'room_id': roomId,
          'contact_id': contactId,
          'linked_at_utc_ms': _milliseconds(_utcNow()),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    });
  }

  @override
  Future<List<RoomRelationCandidate>> listRelationCandidates({
    required String projectId,
    required String roomId,
    required RoomRelationKind kind,
    String? searchText,
    int limit = 100,
  }) async {
    if (limit < 1 || limit > 200) {
      throw RangeError.range(limit, 1, 200, 'limit');
    }
    final normalizedSearch = searchText?.trim().toLowerCase();
    if (normalizedSearch != null && normalizedSearch.length > 120) {
      throw ArgumentError.value(searchText, 'searchText');
    }
    final database = await _database.open();
    await _requiredRoom(database, projectId: projectId, roomId: roomId);
    final searchClause = normalizedSearch == null || normalizedSearch.isEmpty
        ? ''
        : " AND LOWER(source.title) LIKE ? ESCAPE '!'";
    final searchArguments = normalizedSearch == null || normalizedSearch.isEmpty
        ? const <Object?>[]
        : <Object?>[_likePattern(normalizedSearch)];
    final sourceSql = switch (kind) {
      RoomRelationKind.cost =>
        '''
        SELECT e.id, e.name AS title, NULL AS supporting_label
        FROM ${AppDatabase.costEntriesTable} e
        WHERE e.project_id = ? AND e.entry_type IN ('cost', 'planned')
      ''',
      RoomRelationKind.decision =>
        '''
        SELECT j.id, j.title, NULL AS supporting_label
        FROM ${AppDatabase.journalEntriesTable} j
        WHERE j.project_id = ? AND j.entry_type IN ('decision', 'scope_change')
      ''',
      RoomRelationKind.defect =>
        '''
        SELECT j.id, j.title, NULL AS supporting_label
        FROM ${AppDatabase.journalEntriesTable} j
        WHERE j.project_id = ? AND j.entry_type = 'defect'
      ''',
      RoomRelationKind.technicalPhoto =>
        '''
        SELECT t.attachment_id AS id, t.title,
               NULLIF(t.zone_label, '') AS supporting_label
        FROM ${AppDatabase.technicalPhotosTable} t
        WHERE t.project_id = ?
      ''',
      RoomRelationKind.contact =>
        '''
        SELECT c.id, c.display_name AS title,
               NULLIF(c.phone, '') AS supporting_label
        FROM ${AppDatabase.contactsTable} c
        WHERE c.project_id = ? AND c.is_archived = 0
      ''',
    };
    final List<Map<String, Object?>> rows;
    if (kind == RoomRelationKind.contact) {
      rows = await database.rawQuery(
        '''
          SELECT source.*, current.room_id AS assigned_room_id,
                 current_room.name AS assigned_room_name
          FROM ($sourceSql) source
          LEFT JOIN ${AppDatabase.roomContactLinksTable} current
            ON current.project_id = ? AND current.contact_id = source.id
           AND current.room_id = ?
          LEFT JOIN ${AppDatabase.roomsTable} current_room
            ON current_room.project_id = current.project_id
           AND current_room.id = current.room_id
          WHERE 1 = 1$searchClause
          ORDER BY source.title COLLATE NOCASE ASC, source.id ASC
          LIMIT ?
        ''',
        <Object?>[projectId, projectId, roomId, ...searchArguments, limit],
      );
    } else {
      rows = await database.rawQuery(
        '''
          SELECT source.*, current.room_id AS assigned_room_id,
                 current_room.name AS assigned_room_name
          FROM ($sourceSql) source
          LEFT JOIN ${AppDatabase.roomRecordLinksTable} current
            ON current.project_id = ? AND current.record_type = ?
           AND current.record_id = source.id
          LEFT JOIN ${AppDatabase.roomsTable} current_room
            ON current_room.project_id = current.project_id
           AND current_room.id = current.room_id
          WHERE 1 = 1$searchClause
          ORDER BY source.title COLLATE NOCASE ASC, source.id ASC
          LIMIT ?
        ''',
        <Object?>[
          projectId,
          projectId,
          _recordTypeToStorage(_recordTypeFor(kind)),
          ...searchArguments,
          limit,
        ],
      );
    }
    return rows
        .map(
          (row) => RoomRelationCandidate(
            kind: kind,
            id: row['id']! as String,
            title: row['title']! as String,
            supportingLabel: row['supporting_label'] as String?,
            assignedRoomId: row['assigned_room_id'] as String?,
            assignedRoomName: row['assigned_room_name'] as String?,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<RoomChoice> registerChoiceOutput({
    required String projectId,
    required String choiceId,
    required RoomChoiceOutputType outputType,
    required String recordId,
  }) {
    return _database.transaction<RoomChoice>((transaction) async {
      final choice = await _requiredChoice(transaction, projectId, choiceId);
      if (choice.outputRecordId(outputType) != null) {
        throw const RoomChoiceOutputExistsException();
      }
      if (choice.status != RoomChoiceStatus.selected) {
        throw const RoomChoiceOutputUnavailableException();
      }
      final target = switch (outputType) {
        RoomChoiceOutputType.plannedCost => (
          table: AppDatabase.costEntriesTable,
          extraWhere: "entry_type = 'planned'",
        ),
        RoomChoiceOutputType.decision => (
          table: AppDatabase.journalEntriesTable,
          extraWhere: "entry_type IN ('decision', 'scope_change')",
        ),
        RoomChoiceOutputType.material => (
          table: AppDatabase.materialsTable,
          extraWhere: '1 = 1',
        ),
      };
      final records = await transaction.query(
        target.table,
        columns: const <String>['id'],
        where: 'project_id = ? AND id = ? AND ${target.extraWhere}',
        whereArgs: <Object?>[projectId, recordId],
        limit: 1,
      );
      if (records.isEmpty) throw const RoomRelationNotFoundException();
      try {
        await transaction
            .insert(AppDatabase.roomChoiceOutputsTable, <String, Object?>{
              'project_id': projectId,
              'choice_id': choiceId,
              'output_type': _outputTypeToStorage(outputType),
              'record_id': recordId,
              'created_at_utc_ms': _milliseconds(_utcNow()),
            });
      } on DatabaseException {
        throw const RoomChoiceOutputExistsException();
      }
      return _requiredChoice(transaction, projectId, choiceId);
    });
  }

  @override
  Future<RoomPortfolioSummary> summarizeProject(String projectId) async {
    final database = await _database.open();
    final projectRows = await database.query(
      AppDatabase.projectsTable,
      columns: const <String>['currency_code'],
      where: 'id = ?',
      whereArgs: <Object?>[projectId],
      limit: 1,
    );
    if (projectRows.isEmpty) throw const RoomRelationNotFoundException();
    final currency = projectRows.single['currency_code']! as String;
    final rows = await database.rawQuery(
      '''
        SELECT
          (SELECT COUNT(*) FROM ${AppDatabase.roomsTable}
            WHERE project_id = ?) AS room_count,
          (SELECT COALESCE(SUM(planned_budget_minor_units), 0)
            FROM ${AppDatabase.roomsTable}
            WHERE project_id = ?) AS planned_total,
          (SELECT COALESCE(SUM(
              e.gross_minor_units + COALESCE((
                SELECT SUM(c.gross_delta_minor_units)
                FROM ${AppDatabase.costCorrectionsTable} c
                WHERE c.project_id = e.project_id AND c.cost_entry_id = e.id
              ), 0)
            ), 0)
            FROM ${AppDatabase.roomRecordLinksTable} l
            INNER JOIN ${AppDatabase.costEntriesTable} e
              ON e.project_id = l.project_id AND e.id = l.record_id
            WHERE l.project_id = ? AND l.record_type = 'cost'
              AND e.lifecycle = 'confirmed' AND e.entry_type = 'cost'
          ) AS actual_total,
          (SELECT COUNT(*) FROM ${AppDatabase.roomChoicesTable}
            WHERE project_id = ? AND status = 'open') AS open_choice_count
      ''',
      <Object?>[projectId, projectId, projectId, projectId],
    );
    final row = rows.single;
    return RoomPortfolioSummary(
      projectId: projectId,
      roomCount: row['room_count']! as int,
      plannedBudget: Money(
        minorUnits: row['planned_total']! as int,
        currencyCode: currency,
      ),
      actualCost: Money(
        minorUnits: row['actual_total']! as int,
        currencyCode: currency,
      ),
      openChoiceCount: row['open_choice_count']! as int,
    );
  }

  Future<void> _validateProjectAndCurrency(
    DatabaseExecutor executor,
    RoomInput input,
  ) async {
    final rows = await executor.query(
      AppDatabase.projectsTable,
      columns: const <String>['currency_code'],
      where: 'id = ?',
      whereArgs: <Object?>[input.projectId],
      limit: 1,
    );
    if (rows.isEmpty) throw const RoomRelationNotFoundException();
    final budget = input.plannedBudget;
    if (budget != null && budget.currencyCode != rows.single['currency_code']) {
      throw ArgumentError.value(budget.currencyCode, 'plannedBudget');
    }
  }

  Future<void> _validateChoiceInput(
    DatabaseExecutor executor,
    RoomChoiceInput input,
    Iterable<RoomChoiceVariantInput> variants,
  ) async {
    final room = await _requiredRoom(
      executor,
      projectId: input.projectId,
      roomId: input.roomId,
    );
    final currency =
        room.plannedBudget?.currencyCode ??
        (await executor.query(
              AppDatabase.projectsTable,
              columns: const <String>['currency_code'],
              where: 'id = ?',
              whereArgs: <Object?>[input.projectId],
              limit: 1,
            )).single['currency_code']!
            as String;
    for (final variant in variants) {
      if (variant.projectId != input.projectId ||
          variant.unitGrossPrice.currencyCode != currency) {
        throw ArgumentError.value(variant.projectId, 'variants');
      }
    }
  }

  static Future<bool> _recordExists(
    DatabaseExecutor executor, {
    required String projectId,
    required RoomRecordType type,
    required String recordId,
  }) async {
    final (table, idColumn) = switch (type) {
      RoomRecordType.cost => (AppDatabase.costEntriesTable, 'id'),
      RoomRecordType.journal => (AppDatabase.journalEntriesTable, 'id'),
      RoomRecordType.technicalPhoto => (
        AppDatabase.technicalPhotosTable,
        'attachment_id',
      ),
    };
    final rows = await executor.query(
      table,
      columns: <String>[idColumn],
      where: 'project_id = ? AND $idColumn = ?',
      whereArgs: <Object?>[projectId, recordId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  static Future<Room?> _findRoom(
    DatabaseExecutor executor, {
    required String projectId,
    required String roomId,
  }) async {
    final rows = await executor.query(
      AppDatabase.roomsTable,
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, roomId],
      limit: 1,
    );
    return rows.isEmpty ? null : _roomFromRow(rows.single);
  }

  static Future<Room> _requiredRoom(
    DatabaseExecutor executor, {
    required String projectId,
    required String roomId,
  }) async {
    final room = await _findRoom(
      executor,
      projectId: projectId,
      roomId: roomId,
    );
    if (room == null) throw const RoomNotFoundException();
    return room;
  }

  static Future<RoomChoice> _requiredChoice(
    DatabaseExecutor executor,
    String projectId,
    String choiceId,
  ) async {
    final rows = await executor.query(
      AppDatabase.roomChoicesTable,
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, choiceId],
      limit: 1,
    );
    if (rows.isEmpty) throw const RoomChoiceNotFoundException();
    final variants = await _variantsForChoices(
      executor,
      projectId: projectId,
      choiceIds: <String>[choiceId],
    );
    final outputs = await _outputsForChoices(
      executor,
      projectId: projectId,
      choiceIds: <String>[choiceId],
    );
    return _choiceFromRow(
      rows.single,
      variants[choiceId] ?? const [],
      outputs[choiceId] ?? const {},
    );
  }

  static Future<List<RoomChoice>> _listChoices(
    DatabaseExecutor executor, {
    required String projectId,
    required String roomId,
  }) async {
    final rows = await executor.query(
      AppDatabase.roomChoicesTable,
      where: 'project_id = ? AND room_id = ?',
      whereArgs: <Object?>[projectId, roomId],
      orderBy: 'status ASC, updated_at_utc_ms DESC, id ASC',
    );
    if (rows.isEmpty) return const <RoomChoice>[];
    final ids = rows.map((row) => row['id']! as String).toList(growable: false);
    final variants = await _variantsForChoices(
      executor,
      projectId: projectId,
      choiceIds: ids,
    );
    final outputs = await _outputsForChoices(
      executor,
      projectId: projectId,
      choiceIds: ids,
    );
    return rows
        .map(
          (row) => _choiceFromRow(
            row,
            variants[row['id']] ?? const <RoomChoiceVariant>[],
            outputs[row['id']] ?? const <RoomChoiceOutputType, String>{},
          ),
        )
        .toList(growable: false);
  }

  static Future<Map<String, List<RoomChoiceVariant>>> _variantsForChoices(
    DatabaseExecutor executor, {
    required String projectId,
    required List<String> choiceIds,
  }) async {
    if (choiceIds.isEmpty) return const {};
    final rows = await executor.query(
      AppDatabase.roomChoiceVariantsTable,
      where:
          'project_id = ? AND choice_id IN (${_placeholders(choiceIds.length)})',
      whereArgs: <Object?>[projectId, ...choiceIds],
      orderBy: 'created_at_utc_ms ASC, id ASC',
    );
    final result = <String, List<RoomChoiceVariant>>{};
    for (final row in rows) {
      (result[row['choice_id']! as String] ??= <RoomChoiceVariant>[]).add(
        _variantFromRow(row),
      );
    }
    return result;
  }

  static Future<Map<String, Map<RoomChoiceOutputType, String>>>
  _outputsForChoices(
    DatabaseExecutor executor, {
    required String projectId,
    required List<String> choiceIds,
  }) async {
    if (choiceIds.isEmpty) return const {};
    final rows = await executor.query(
      AppDatabase.roomChoiceOutputsTable,
      where:
          'project_id = ? AND choice_id IN (${_placeholders(choiceIds.length)})',
      whereArgs: <Object?>[projectId, ...choiceIds],
    );
    final result = <String, Map<RoomChoiceOutputType, String>>{};
    for (final row in rows) {
      (result[row['choice_id']! as String] ??=
              <RoomChoiceOutputType, String>{})[_outputTypeFromStorage(
            row['output_type']! as String,
          )] =
          row['record_id']! as String;
    }
    return result;
  }
}

const String _roomOverviewSelect =
    '''
  SELECT
    r.*,
    p.currency_code AS project_currency_code,
    COALESCE((
      SELECT SUM(
        e.gross_minor_units + COALESCE((
          SELECT SUM(c.gross_delta_minor_units)
          FROM ${AppDatabase.costCorrectionsTable} c
          WHERE c.project_id = e.project_id AND c.cost_entry_id = e.id
        ), 0)
      )
      FROM ${AppDatabase.roomRecordLinksTable} l
      INNER JOIN ${AppDatabase.costEntriesTable} e
        ON e.project_id = l.project_id AND e.id = l.record_id
      WHERE l.project_id = r.project_id AND l.room_id = r.id
        AND l.record_type = 'cost'
        AND e.lifecycle = 'confirmed' AND e.entry_type = 'cost'
    ), 0) AS actual_cost_minor_units,
    (SELECT COUNT(*) FROM ${AppDatabase.roomChoicesTable} ch
      WHERE ch.project_id = r.project_id AND ch.room_id = r.id
        AND ch.status = 'open') AS open_choice_count,
    (SELECT COUNT(*)
      FROM ${AppDatabase.roomRecordLinksTable} l
      INNER JOIN ${AppDatabase.journalEntriesTable} j
        ON j.project_id = l.project_id AND j.id = l.record_id
      WHERE l.project_id = r.project_id AND l.room_id = r.id
        AND l.record_type = 'journal'
        AND j.entry_type IN ('decision', 'scope_change')
        AND j.status NOT IN ('rejected', 'implemented', 'closed')
    ) AS open_decision_count,
    (SELECT COUNT(*) FROM ${AppDatabase.materialsTable} m
      WHERE m.project_id = r.project_id AND m.room_id = r.id
    ) AS material_count,
    (SELECT COUNT(*) FROM ${AppDatabase.roomContactLinksTable} rc
      WHERE rc.project_id = r.project_id AND rc.room_id = r.id
    ) AS contact_count,
    (SELECT COUNT(*) FROM ${AppDatabase.roomRecordLinksTable} l
      INNER JOIN ${AppDatabase.technicalPhotosTable} t
        ON t.project_id = l.project_id AND t.attachment_id = l.record_id
      WHERE l.project_id = r.project_id AND l.room_id = r.id
        AND l.record_type = 'technical_photo'
    ) AS technical_photo_count,
    (SELECT COUNT(*)
      FROM ${AppDatabase.roomRecordLinksTable} l
      INNER JOIN ${AppDatabase.journalEntriesTable} j
        ON j.project_id = l.project_id AND j.id = l.record_id
      WHERE l.project_id = r.project_id AND l.room_id = r.id
        AND l.record_type = 'journal' AND j.entry_type = 'defect'
        AND j.status != 'closed'
    ) AS open_defect_count
  FROM ${AppDatabase.roomsTable} r
  INNER JOIN ${AppDatabase.projectsTable} p ON p.id = r.project_id
''';

({String sql, List<Object?> arguments}) _roomFilter(RoomQuery query) {
  final clauses = <String>['r.project_id = ?'];
  final arguments = <Object?>[query.projectId];
  final search = query.searchText;
  if (search != null) {
    clauses.add(
      "(LOWER(r.name) LIKE ? ESCAPE '!' OR LOWER(r.floor_label) LIKE ? ESCAPE '!')",
    );
    final pattern = _likePattern(search);
    arguments.addAll(<Object?>[pattern, pattern]);
  }
  return (sql: clauses.join(' AND '), arguments: arguments);
}

RoomOverview _overviewFromRow(Map<String, Object?> row) {
  final room = _roomFromRow(row);
  return RoomOverview(
    room: room,
    actualCost: Money(
      minorUnits: row['actual_cost_minor_units']! as int,
      currencyCode: row['project_currency_code']! as String,
    ),
    openChoiceCount: row['open_choice_count']! as int,
    openDecisionCount: row['open_decision_count']! as int,
    materialCount: row['material_count']! as int,
    contactCount: row['contact_count']! as int,
    technicalPhotoCount: row['technical_photo_count']! as int,
    openDefectCount: row['open_defect_count']! as int,
  );
}

Map<String, Object?> _roomToRow(Room room) {
  final dimensions = room.dimensions;
  final budget = room.plannedBudget;
  return <String, Object?>{
    'id': room.id,
    'project_id': room.projectId,
    'name': room.name,
    'floor_label': room.floorLabel ?? '',
    'standard': room.standard.name,
    'length_mm': dimensions?.lengthMillimeters,
    'width_mm': dimensions?.widthMillimeters,
    'height_mm': dimensions?.heightMillimeters,
    'planned_budget_minor_units': budget?.minorUnits,
    'currency_code': budget?.currencyCode,
    'note': room.note,
    'created_at_utc_ms': _milliseconds(room.createdAtUtc),
    'updated_at_utc_ms': _milliseconds(room.updatedAtUtc),
  };
}

Room _roomFromRow(Map<String, Object?> row) {
  final length = row['length_mm'] as int?;
  final width = row['width_mm'] as int?;
  final height = row['height_mm'] as int?;
  final budget = row['planned_budget_minor_units'] as int?;
  return Room(
    id: row['id']! as String,
    input: RoomInput(
      projectId: row['project_id']! as String,
      name: row['name']! as String,
      floorLabel: row['floor_label'] as String?,
      standard: RoomStandard.values.firstWhere(
        (value) => value.name == row['standard'],
      ),
      dimensions: length == null && width == null && height == null
          ? null
          : RoomDimensions(
              lengthMillimeters: length,
              widthMillimeters: width,
              heightMillimeters: height,
            ),
      plannedBudget: budget == null
          ? null
          : Money(
              minorUnits: budget,
              currencyCode: row['currency_code']! as String,
            ),
      note: row['note'] as String?,
    ),
    createdAt: _dateTime(row['created_at_utc_ms']!),
    updatedAt: _dateTime(row['updated_at_utc_ms']!),
  );
}

Map<String, Object?> _choiceInputToRow({
  required String id,
  required RoomChoiceInput input,
  required RoomChoiceStatus status,
  required DateTime createdAt,
  required DateTime updatedAt,
}) {
  return <String, Object?>{
    'id': id,
    'project_id': input.projectId,
    'room_id': input.roomId,
    'title': input.title,
    'status': status.name,
    'quantity_unscaled': input.quantity?.unscaledValue,
    'quantity_scale': input.quantity?.scale,
    'unit': input.unit,
    'waste_basis_points': input.wasteBasisPoints,
    'order_due_utc_ms': input.orderDueUtc == null
        ? null
        : _milliseconds(input.orderDueUtc!),
    'note': input.note,
    'created_at_utc_ms': _milliseconds(createdAt),
    'updated_at_utc_ms': _milliseconds(updatedAt),
  };
}

Map<String, Object?> _variantInputToRow({
  required String id,
  required String choiceId,
  required RoomChoiceVariantInput input,
  required bool isSelected,
  required DateTime createdAt,
  required DateTime updatedAt,
}) {
  return <String, Object?>{
    'id': id,
    'project_id': input.projectId,
    'choice_id': choiceId,
    'label': input.label,
    'supplier': input.supplier,
    'product_code': input.productCode,
    'unit_gross_minor_units': input.unitGrossPrice.minorUnits,
    'currency_code': input.unitGrossPrice.currencyCode,
    'is_selected': isSelected ? 1 : 0,
    'note': input.note,
    'created_at_utc_ms': _milliseconds(createdAt),
    'updated_at_utc_ms': _milliseconds(updatedAt),
  };
}

RoomChoice _choiceFromRow(
  Map<String, Object?> row,
  List<RoomChoiceVariant> variants,
  Map<RoomChoiceOutputType, String> outputRecordIds,
) {
  final quantityUnscaled = row['quantity_unscaled'] as int?;
  final quantityScale = row['quantity_scale'] as int?;
  String? selectedVariantId;
  for (final variantRow in variants) {
    if (variantRow.isSelected) {
      selectedVariantId = variantRow.id;
      break;
    }
  }
  // Selection is read separately because the public variant model intentionally
  // contains only user data.
  return RoomChoice(
    id: row['id']! as String,
    input: RoomChoiceInput(
      projectId: row['project_id']! as String,
      roomId: row['room_id']! as String,
      title: row['title']! as String,
      quantity: quantityUnscaled == null || quantityScale == null
          ? null
          : DecimalQuantity(
              unscaledValue: quantityUnscaled,
              scale: quantityScale,
            ),
      unit: row['unit'] as String?,
      wasteBasisPoints: row['waste_basis_points']! as int,
      orderDue: row['order_due_utc_ms'] == null
          ? null
          : _dateTime(row['order_due_utc_ms']!),
      note: row['note'] as String?,
    ),
    variants: variants,
    status: RoomChoiceStatus.values.firstWhere(
      (value) => value.name == row['status'],
    ),
    selectedVariantId: selectedVariantId,
    outputRecordIds: outputRecordIds,
    createdAt: _dateTime(row['created_at_utc_ms']!),
    updatedAt: _dateTime(row['updated_at_utc_ms']!),
  );
}

RoomChoiceVariant _variantFromRow(Map<String, Object?> row) {
  return RoomChoiceVariant(
    id: row['id']! as String,
    choiceId: row['choice_id']! as String,
    input: RoomChoiceVariantInput(
      projectId: row['project_id']! as String,
      label: row['label']! as String,
      supplier: row['supplier'] as String?,
      productCode: row['product_code'] as String?,
      unitGrossPrice: Money(
        minorUnits: row['unit_gross_minor_units']! as int,
        currencyCode: row['currency_code']! as String,
      ),
      note: row['note'] as String?,
    ),
    isSelected: row['is_selected'] == 1,
    createdAt: _dateTime(row['created_at_utc_ms']!),
    updatedAt: _dateTime(row['updated_at_utc_ms']!),
  );
}

String _recordTypeToStorage(RoomRecordType value) => switch (value) {
  RoomRecordType.cost => 'cost',
  RoomRecordType.journal => 'journal',
  RoomRecordType.technicalPhoto => 'technical_photo',
};

String _outputTypeToStorage(RoomChoiceOutputType value) => switch (value) {
  RoomChoiceOutputType.plannedCost => 'planned_cost',
  RoomChoiceOutputType.decision => 'decision',
  RoomChoiceOutputType.material => 'material',
};

RoomChoiceOutputType _outputTypeFromStorage(String value) => switch (value) {
  'planned_cost' => RoomChoiceOutputType.plannedCost,
  'decision' => RoomChoiceOutputType.decision,
  'material' => RoomChoiceOutputType.material,
  _ => throw StateError('Unsupported room choice output type'),
};

RoomRecordType _recordTypeFor(RoomRelationKind kind) => switch (kind) {
  RoomRelationKind.cost => RoomRecordType.cost,
  RoomRelationKind.decision ||
  RoomRelationKind.defect => RoomRecordType.journal,
  RoomRelationKind.technicalPhoto => RoomRecordType.technicalPhoto,
  RoomRelationKind.contact => throw ArgumentError.value(kind, 'kind'),
};

String _placeholders(int count) => List<String>.filled(count, '?').join(', ');

String _likePattern(String value) {
  final escaped = value
      .replaceAll('!', '!!')
      .replaceAll('%', '!%')
      .replaceAll('_', '!_');
  return '%$escaped%';
}

int _milliseconds(DateTime value) =>
    DatabaseValueCodec.dateTimeToUtcMilliseconds(value);

DateTime _dateTime(Object value) =>
    DatabaseValueCodec.utcMillisecondsToDateTime(value as int);
