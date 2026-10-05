import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/materials/domain/material.dart';
import 'package:budowapro/features/materials/domain/material_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:sqflite/sqflite.dart';

typedef MaterialIdGenerator = String Function();
typedef MaterialUtcNow = DateTime Function();

final class SqliteMaterialRepository implements MaterialRepository {
  factory SqliteMaterialRepository({
    required AppDatabase database,
    required MaterialIdGenerator idGenerator,
    required MaterialUtcNow utcNow,
  }) => SqliteMaterialRepository._(database, idGenerator, utcNow);

  const SqliteMaterialRepository._(
    this._database,
    this._idGenerator,
    this._utcNow,
  );

  final AppDatabase _database;
  final MaterialIdGenerator _idGenerator;
  final MaterialUtcNow _utcNow;

  @override
  Future<Page<MaterialItem>> list(
    MaterialQuery query,
    PageRequest request, {
    required DateTime now,
  }) async {
    final database = await _database.open();
    final where = <String>['project_id = ?'];
    final arguments = <Object?>[
      DatabaseValueCodec.dateTimeToUtcMilliseconds(now),
      DatabaseValueCodec.dateTimeToUtcMilliseconds(now),
      query.projectId,
    ];
    final search = query.searchText;
    if (search != null) {
      where.add(
        "(lower(name) LIKE ? ESCAPE '\\' OR "
        "lower(COALESCE(storage_location, '')) LIKE ? ESCAPE '\\')",
      );
      final pattern = '%${_escapeLike(search)}%';
      arguments.addAll(<Object?>[pattern, pattern]);
    }
    if (query.stageId case final stageId?) {
      where.add('stage_id = ?');
      arguments.add(stageId);
    }
    if (query.roomId case final roomId?) {
      where.add('room_id = ?');
      arguments.add(roomId);
    }
    if (query.statuses.isNotEmpty) {
      where.add(
        'status IN (${List.filled(query.statuses.length, '?').join(', ')})',
      );
      arguments.addAll(query.statuses.map(_statusToStorage));
    }
    final clause = where.join(' AND ');
    final countRows = await database.rawQuery(
      '$_materialStateCte SELECT COUNT(*) AS total '
      'FROM material_state WHERE $clause',
      arguments,
    );
    final rows = await database.rawQuery(
      '$_materialStateCte SELECT * FROM material_state WHERE $clause '
      'ORDER BY updated_at_utc_ms DESC, id ASC LIMIT ? OFFSET ?',
      <Object?>[...arguments, request.limit, request.offset],
    );
    final items = await _hydrate(database, rows);
    return Page<MaterialItem>(
      items: items,
      totalCount: countRows.single['total']! as int,
      request: request,
    );
  }

  @override
  Future<MaterialItem?> findById({
    required String projectId,
    required String materialId,
  }) async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.materialsTable,
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, materialId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return (await _hydrate(database, rows)).single;
  }

  @override
  Future<MaterialItem> create(MaterialInput input) {
    return _database.transaction<MaterialItem>((transaction) async {
      await _validateInputRelations(transaction, input);
      final now = _utcNow().toUtc();
      final id = _idGenerator();
      await transaction.insert(
        AppDatabase.materialsTable,
        _materialRow(id: id, input: input, createdAt: now, updatedAt: now),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return MaterialItem(
        id: id,
        input: input,
        deliveries: const <MaterialDelivery>[],
        returns: const <MaterialReturn>[],
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  @override
  Future<MaterialItem> update({
    required String projectId,
    required String materialId,
    required MaterialInput input,
  }) {
    if (input.projectId != projectId) {
      throw ArgumentError.value(input.projectId, 'input.projectId');
    }
    return _database.transaction<MaterialItem>((transaction) async {
      final existing = await _findMaterialRow(
        transaction,
        projectId,
        materialId,
      );
      await _validateInputRelations(transaction, input);
      final now = _utcNow().toUtc();
      await transaction.update(
        AppDatabase.materialsTable,
        _materialRow(
          id: materialId,
          input: input,
          createdAt: _date(existing['created_at_utc_ms']),
          updatedAt: now,
        ),
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, materialId],
      );
      return (await _hydrate(transaction, <Map<String, Object?>>[
        <String, Object?>{
          ...existing,
          ..._materialRow(
            id: materialId,
            input: input,
            createdAt: _date(existing['created_at_utc_ms']),
            updatedAt: now,
          ),
        },
      ])).single;
    });
  }

  @override
  Future<void> delete({required String projectId, required String materialId}) {
    return _database.transaction<void>((transaction) async {
      await _findMaterialRow(transaction, projectId, materialId);
      final deliveryCount = Sqflite.firstIntValue(
        await transaction.rawQuery(
          'SELECT COUNT(*) FROM ${AppDatabase.materialDeliveriesTable} '
          'WHERE project_id = ? AND material_id = ?',
          <Object?>[projectId, materialId],
        ),
      )!;
      final returnCount = Sqflite.firstIntValue(
        await transaction.rawQuery(
          'SELECT COUNT(*) FROM ${AppDatabase.materialReturnsTable} '
          'WHERE project_id = ? AND material_id = ?',
          <Object?>[projectId, materialId],
        ),
      )!;
      if (deliveryCount > 0 || returnCount > 0) {
        throw MaterialInUseException(
          deliveryCount: deliveryCount,
          returnCount: returnCount,
        );
      }
      await transaction.delete(
        AppDatabase.roomChoiceOutputsTable,
        where: 'project_id = ? AND output_type = ? AND record_id = ?',
        whereArgs: <Object?>[projectId, 'material', materialId],
      );
      final changed = await transaction.delete(
        AppDatabase.materialsTable,
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, materialId],
      );
      if (changed == 0) throw const MaterialNotFoundException();
    });
  }

  @override
  Future<MaterialDelivery> saveDelivery({
    String? deliveryId,
    required MaterialDeliveryInput input,
    bool confirmOrderedQuantityCorrection = false,
  }) {
    return _database.transaction<MaterialDelivery>((transaction) async {
      final material = await _findMaterialRow(
        transaction,
        input.projectId,
        input.materialId,
      );
      await _validateTarget(
        transaction,
        projectId: input.projectId,
        table: AppDatabase.documentMetadataTable,
        idColumn: 'attachment_id',
        id: input.documentId,
        kind: 'document',
      );
      await _validateTarget(
        transaction,
        projectId: input.projectId,
        table: AppDatabase.contactsTable,
        idColumn: 'id',
        id: input.contactId,
        kind: 'contact',
      );
      final id = deliveryId ?? _idGenerator();
      Map<String, Object?>? existing;
      if (deliveryId != null) {
        existing = await _findChildRow(
          transaction,
          table: AppDatabase.materialDeliveriesTable,
          projectId: input.projectId,
          materialId: input.materialId,
          id: deliveryId,
          notFound: const MaterialDeliveryNotFoundException(),
        );
      }
      final deliveredMicrounits = input.deliveredQuantity == null
          ? 0
          : _quantityToMicrounits(input.deliveredQuantity!);
      final totals = await transaction.rawQuery(
        '''
          SELECT COALESCE(SUM(delivered_quantity_microunits), 0) AS total
          FROM ${AppDatabase.materialDeliveriesTable}
          WHERE project_id = ? AND material_id = ? AND id != ?
        ''',
        <Object?>[input.projectId, input.materialId, id],
      );
      final deliveredTotal =
          (totals.single['total']! as int) + deliveredMicrounits;
      final ordered = material['ordered_quantity_microunits']! as int;
      final overDelivered = deliveredTotal > ordered;
      final correctionConfirmed =
          confirmOrderedQuantityCorrection || input.overDeliveryConfirmed;
      if (overDelivered && !correctionConfirmed) {
        throw const MaterialOverDeliveryConfirmationRequired();
      }
      final now = _utcNow().toUtc();
      if (overDelivered) {
        await transaction.update(
          AppDatabase.materialsTable,
          <String, Object?>{
            'ordered_quantity_microunits': deliveredTotal,
            'updated_at_utc_ms': _dateToStorage(now),
          },
          where: 'project_id = ? AND id = ?',
          whereArgs: <Object?>[input.projectId, input.materialId],
        );
      }
      final row = _deliveryRow(
        id: id,
        input: input,
        overDeliveryConfirmed: overDelivered && correctionConfirmed,
        createdAt: existing == null
            ? now
            : _date(existing['created_at_utc_ms']),
        updatedAt: now,
      );
      if (existing == null) {
        await transaction.insert(AppDatabase.materialDeliveriesTable, row);
      } else {
        await transaction.update(
          AppDatabase.materialDeliveriesTable,
          row,
          where: 'project_id = ? AND material_id = ? AND id = ?',
          whereArgs: <Object?>[input.projectId, input.materialId, id],
        );
      }
      await _touchMaterial(transaction, input.projectId, input.materialId, now);
      return _deliveryFromRow(row);
    });
  }

  @override
  Future<void> deleteDelivery({
    required String projectId,
    required String materialId,
    required String deliveryId,
  }) async {
    await _database.transaction<void>((transaction) async {
      final changed = await transaction.delete(
        AppDatabase.materialDeliveriesTable,
        where: 'project_id = ? AND material_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, materialId, deliveryId],
      );
      if (changed == 0) throw const MaterialDeliveryNotFoundException();
      await _touchMaterial(transaction, projectId, materialId, _utcNow());
    });
  }

  @override
  Future<MaterialReturn> saveReturn({
    String? returnId,
    required MaterialReturnInput input,
  }) {
    return _database.transaction<MaterialReturn>((transaction) async {
      final material = await _findMaterialRow(
        transaction,
        input.projectId,
        input.materialId,
      );
      await _validateTarget(
        transaction,
        projectId: input.projectId,
        table: AppDatabase.documentMetadataTable,
        idColumn: 'attachment_id',
        id: input.receiptDocumentId,
        kind: 'document',
      );
      final projectCurrency = await _projectCurrency(
        transaction,
        input.projectId,
      );
      for (final money in <Money?>[input.expectedRefund, input.actualRefund]) {
        if (money != null && money.currencyCode != projectCurrency) {
          throw ArgumentError.value(money.currencyCode, 'refundCurrency');
        }
      }
      final id = returnId ?? _idGenerator();
      Map<String, Object?>? existing;
      if (returnId != null) {
        existing = await _findChildRow(
          transaction,
          table: AppDatabase.materialReturnsTable,
          projectId: input.projectId,
          materialId: input.materialId,
          id: returnId,
          notFound: const MaterialReturnNotFoundException(),
        );
      }
      final otherRows = await transaction.rawQuery(
        '''
          SELECT COALESCE(SUM(quantity_microunits), 0) AS total
          FROM ${AppDatabase.materialReturnsTable}
          WHERE project_id = ? AND material_id = ? AND id != ?
        ''',
        <Object?>[input.projectId, input.materialId, id],
      );
      final proposedTotal =
          (otherRows.single['total']! as int) +
          _quantityToMicrounits(input.quantity);
      var maximum = material['ordered_quantity_microunits']! as int;
      if (input.completedAtUtc != null) {
        final deliveredRows = await transaction.rawQuery(
          '''
            SELECT COALESCE(SUM(delivered_quantity_microunits), 0) AS total
            FROM ${AppDatabase.materialDeliveriesTable}
            WHERE project_id = ? AND material_id = ?
          ''',
          <Object?>[input.projectId, input.materialId],
        );
        maximum = deliveredRows.single['total']! as int;
      }
      if (proposedTotal > maximum) {
        throw RangeError('Return quantity exceeds available material');
      }
      final now = _utcNow().toUtc();
      final row = _returnRow(
        id: id,
        input: input,
        createdAt: existing == null
            ? now
            : _date(existing['created_at_utc_ms']),
        updatedAt: now,
      );
      if (existing == null) {
        await transaction.insert(AppDatabase.materialReturnsTable, row);
      } else {
        await transaction.update(
          AppDatabase.materialReturnsTable,
          row,
          where: 'project_id = ? AND material_id = ? AND id = ?',
          whereArgs: <Object?>[input.projectId, input.materialId, id],
        );
      }
      await _touchMaterial(transaction, input.projectId, input.materialId, now);
      return _returnFromRow(row);
    });
  }

  @override
  Future<void> deleteReturn({
    required String projectId,
    required String materialId,
    required String returnId,
  }) async {
    await _database.transaction<void>((transaction) async {
      final changed = await transaction.delete(
        AppDatabase.materialReturnsTable,
        where: 'project_id = ? AND material_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, materialId, returnId],
      );
      if (changed == 0) throw const MaterialReturnNotFoundException();
      await _touchMaterial(transaction, projectId, materialId, _utcNow());
    });
  }

  @override
  Future<MaterialDashboardSummary> summarize({
    required String projectId,
    required String currencyCode,
    required DateTime now,
  }) async {
    final database = await _database.open();
    final nowMs = _dateToStorage(now);
    final rows = await database.rawQuery(
      '''
        $_materialStateCte
        SELECT
          COALESCE((
            SELECT SUM(ordered_gross_minor_units)
            FROM material_state
            WHERE project_id = ? AND currency_code = ?
          ), 0) AS ordered_value,
          COALESCE((
            SELECT SUM(expected_refund_minor_units)
            FROM ${AppDatabase.materialReturnsTable}
            WHERE project_id = ? AND completed_at_utc_ms IS NULL
              AND currency_code = ?
          ), 0) AS return_value,
          (SELECT COUNT(*) FROM material_state
            WHERE project_id = ? AND status = 'delayed') AS delayed_count,
          (SELECT COUNT(*) FROM ${AppDatabase.materialReturnsTable}
            WHERE project_id = ? AND completed_at_utc_ms IS NULL
              AND deadline_utc_ms < ?) AS overdue_return_count,
          (SELECT COUNT(*) FROM ${AppDatabase.materialDeliveriesTable}
            WHERE project_id = ? AND received_at_utc_ms IS NULL)
            AS open_delivery_count
      ''',
      <Object?>[
        nowMs,
        nowMs,
        projectId,
        currencyCode,
        projectId,
        currencyCode,
        projectId,
        projectId,
        nowMs,
        projectId,
      ],
    );
    final row = rows.single;
    return MaterialDashboardSummary(
      projectId: projectId,
      orderedValue: Money(
        minorUnits: row['ordered_value']! as int,
        currencyCode: currencyCode,
      ),
      expectedReturnValue: Money(
        minorUnits: row['return_value']! as int,
        currencyCode: currencyCode,
      ),
      delayedCount: row['delayed_count']! as int,
      overdueReturnCount: row['overdue_return_count']! as int,
      openDeliveryCount: row['open_delivery_count']! as int,
    );
  }

  Future<List<MaterialItem>> _hydrate(
    DatabaseExecutor executor,
    List<Map<String, Object?>> materialRows,
  ) async {
    if (materialRows.isEmpty) return const <MaterialItem>[];
    final ids = materialRows.map((row) => row['id']! as String).toList();
    final placeholders = List.filled(ids.length, '?').join(', ');
    final projectId = materialRows.first['project_id']! as String;
    final deliveries = await executor.rawQuery(
      'SELECT * FROM ${AppDatabase.materialDeliveriesTable} '
      'WHERE project_id = ? AND material_id IN ($placeholders) '
      'ORDER BY due_at_utc_ms ASC, id ASC',
      <Object?>[projectId, ...ids],
    );
    final returns = await executor.rawQuery(
      'SELECT * FROM ${AppDatabase.materialReturnsTable} '
      'WHERE project_id = ? AND material_id IN ($placeholders) '
      'ORDER BY deadline_utc_ms ASC, id ASC',
      <Object?>[projectId, ...ids],
    );
    final deliveriesByMaterial = <String, List<MaterialDelivery>>{};
    for (final row in deliveries) {
      deliveriesByMaterial
          .putIfAbsent(row['material_id']! as String, () => [])
          .add(_deliveryFromRow(row));
    }
    final returnsByMaterial = <String, List<MaterialReturn>>{};
    for (final row in returns) {
      returnsByMaterial
          .putIfAbsent(row['material_id']! as String, () => [])
          .add(_returnFromRow(row));
    }
    return materialRows
        .map(
          (row) => MaterialItem(
            id: row['id']! as String,
            input: _materialInputFromRow(row),
            deliveries:
                deliveriesByMaterial[row['id']] ?? const <MaterialDelivery>[],
            returns: returnsByMaterial[row['id']] ?? const <MaterialReturn>[],
            createdAt: _date(row['created_at_utc_ms']),
            updatedAt: _date(row['updated_at_utc_ms']),
          ),
        )
        .toList(growable: false);
  }

  Future<void> _validateInputRelations(
    DatabaseExecutor executor,
    MaterialInput input,
  ) async {
    final currency = await _projectCurrency(executor, input.projectId);
    if (input.orderedGross != null &&
        input.orderedGross!.currencyCode != currency) {
      throw ArgumentError.value(input.orderedGross!.currencyCode, 'currency');
    }
    if (input.stageId case final stageId?) {
      if (!_builtInStageIds.contains(stageId)) {
        final rows = await executor.rawQuery(
          'SELECT id FROM ${AppDatabase.projectStagesTable} '
          'WHERE project_id = ? AND (id = ? OR template_stage_key = ?) LIMIT 1',
          <Object?>[input.projectId, stageId, stageId],
        );
        if (rows.isEmpty) {
          throw const MaterialRelationNotFoundException('stage');
        }
      }
    }
    await _validateTarget(
      executor,
      projectId: input.projectId,
      table: AppDatabase.roomsTable,
      idColumn: 'id',
      id: input.roomId,
      kind: 'room',
    );
    await _validateTarget(
      executor,
      projectId: input.projectId,
      table: AppDatabase.contactsTable,
      idColumn: 'id',
      id: input.supplierContactId,
      kind: 'contact',
    );
    await _validateTarget(
      executor,
      projectId: input.projectId,
      table: AppDatabase.costEntriesTable,
      idColumn: 'id',
      id: input.costEntryId,
      kind: 'cost',
    );
    await _validateTarget(
      executor,
      projectId: input.projectId,
      table: AppDatabase.documentMetadataTable,
      idColumn: 'attachment_id',
      id: input.receiptDocumentId,
      kind: 'document',
    );
  }

  static Future<String> _projectCurrency(
    DatabaseExecutor executor,
    String projectId,
  ) async {
    final rows = await executor.query(
      AppDatabase.projectsTable,
      columns: const <String>['currency_code'],
      where: 'id = ?',
      whereArgs: <Object?>[projectId],
      limit: 1,
    );
    if (rows.isEmpty) throw const MaterialRelationNotFoundException('project');
    return rows.single['currency_code']! as String;
  }

  static Future<void> _validateTarget(
    DatabaseExecutor executor, {
    required String projectId,
    required String table,
    required String idColumn,
    required String? id,
    required String kind,
  }) async {
    if (id == null) return;
    final rows = await executor.query(
      table,
      columns: <String>[idColumn],
      where: 'project_id = ? AND $idColumn = ?',
      whereArgs: <Object?>[projectId, id],
      limit: 1,
    );
    if (rows.isEmpty) throw MaterialRelationNotFoundException(kind);
  }

  static Future<Map<String, Object?>> _findMaterialRow(
    DatabaseExecutor executor,
    String projectId,
    String materialId,
  ) async {
    final rows = await executor.query(
      AppDatabase.materialsTable,
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, materialId],
      limit: 1,
    );
    if (rows.isEmpty) throw const MaterialNotFoundException();
    return rows.single;
  }

  static Future<Map<String, Object?>> _findChildRow(
    DatabaseExecutor executor, {
    required String table,
    required String projectId,
    required String materialId,
    required String id,
    required Object notFound,
  }) async {
    final rows = await executor.query(
      table,
      where: 'project_id = ? AND material_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, materialId, id],
      limit: 1,
    );
    if (rows.isEmpty) throw notFound;
    return rows.single;
  }

  static Future<void> _touchMaterial(
    DatabaseExecutor executor,
    String projectId,
    String materialId,
    DateTime now,
  ) async {
    await executor.update(
      AppDatabase.materialsTable,
      <String, Object?>{'updated_at_utc_ms': _dateToStorage(now)},
      where: 'project_id = ? AND id = ?',
      whereArgs: <Object?>[projectId, materialId],
    );
  }
}

const String _materialStateCte = '''
  WITH delivered AS (
    SELECT project_id, material_id,
      COALESCE(SUM(delivered_quantity_microunits), 0) AS delivered_total
    FROM material_deliveries
    GROUP BY project_id, material_id
  ), returned AS (
    SELECT project_id, material_id,
      COALESCE(SUM(quantity_microunits), 0) AS returned_total
    FROM material_returns
    WHERE completed_at_utc_ms IS NOT NULL
    GROUP BY project_id, material_id
  ), delayed AS (
    SELECT project_id, material_id, 1 AS is_delayed
    FROM material_deliveries
    WHERE received_at_utc_ms IS NULL AND due_at_utc_ms < ?
    GROUP BY project_id, material_id
  ), material_state AS (
    SELECT material.*,
      CASE
        WHEN COALESCE(delivered.delivered_total, 0) > 0
          AND COALESCE(returned.returned_total, 0) >= delivered.delivered_total
          THEN 'returned'
        WHEN COALESCE(delivered.delivered_total, 0) >=
          material.ordered_quantity_microunits THEN 'delivered'
        WHEN COALESCE(delivered.delivered_total, 0) > 0
          THEN 'partially_delivered'
        WHEN COALESCE(delayed.is_delayed, 0) = 1
          OR (material.ordered_at_utc_ms IS NOT NULL
            AND material.expected_delivery_at_utc_ms IS NOT NULL
            AND material.expected_delivery_at_utc_ms < ?)
          THEN 'delayed'
        WHEN material.ordered_at_utc_ms IS NOT NULL THEN 'ordered'
        ELSE 'planned'
      END AS status
    FROM materials material
    LEFT JOIN delivered ON delivered.project_id = material.project_id
      AND delivered.material_id = material.id
    LEFT JOIN returned ON returned.project_id = material.project_id
      AND returned.material_id = material.id
    LEFT JOIN delayed ON delayed.project_id = material.project_id
      AND delayed.material_id = material.id
  )
''';

const Set<String> _builtInStageIds = <String>{
  'planning',
  'formalities',
  'site_preparation',
  'state_zero',
  'shell_open',
  'shell_closed',
  'demolition',
  'installations',
  'plaster',
  'finishing',
  'handover',
};

Map<String, Object?> _materialRow({
  required String id,
  required MaterialInput input,
  required DateTime createdAt,
  required DateTime updatedAt,
}) {
  return <String, Object?>{
    'id': id,
    'project_id': input.projectId,
    'name': input.name,
    'ordered_quantity_microunits': _quantityToMicrounits(input.orderedQuantity),
    'unit': input.unit,
    'stage_id': input.stageId,
    'room_id': input.roomId,
    'supplier_contact_id': input.supplierContactId,
    'cost_entry_id': input.costEntryId,
    'receipt_document_id': input.receiptDocumentId,
    'ordered_gross_minor_units': input.orderedGross?.minorUnits,
    'currency_code': input.orderedGross?.currencyCode,
    'storage_location': input.storageLocation,
    'ordered_at_utc_ms': _optionalDateToStorage(input.orderedAtUtc),
    'expected_delivery_at_utc_ms': _optionalDateToStorage(
      input.expectedDeliveryAtUtc,
    ),
    'delivery_reminder_enabled': input.deliveryReminderEnabled ? 1 : 0,
    'note': input.note,
    'created_at_utc_ms': _dateToStorage(createdAt),
    'updated_at_utc_ms': _dateToStorage(updatedAt),
  };
}

MaterialInput _materialInputFromRow(Map<String, Object?> row) {
  final gross = row['ordered_gross_minor_units'] as int?;
  return MaterialInput(
    projectId: row['project_id']! as String,
    name: row['name']! as String,
    orderedQuantity: _quantityFromMicrounits(
      row['ordered_quantity_microunits']! as int,
    ),
    unit: row['unit']! as String,
    stageId: row['stage_id'] as String?,
    roomId: row['room_id'] as String?,
    supplierContactId: row['supplier_contact_id'] as String?,
    costEntryId: row['cost_entry_id'] as String?,
    receiptDocumentId: row['receipt_document_id'] as String?,
    orderedGross: gross == null
        ? null
        : Money(
            minorUnits: gross,
            currencyCode: row['currency_code']! as String,
          ),
    storageLocation: row['storage_location'] as String?,
    orderedAt: _optionalDate(row['ordered_at_utc_ms']),
    expectedDeliveryAt: _optionalDate(row['expected_delivery_at_utc_ms']),
    deliveryReminderEnabled: row['delivery_reminder_enabled'] == 1,
    note: row['note'] as String?,
  );
}

Map<String, Object?> _deliveryRow({
  required String id,
  required MaterialDeliveryInput input,
  required bool overDeliveryConfirmed,
  required DateTime createdAt,
  required DateTime updatedAt,
}) {
  return <String, Object?>{
    'id': id,
    'project_id': input.projectId,
    'material_id': input.materialId,
    'expected_quantity_microunits': _quantityToMicrounits(
      input.expectedQuantity,
    ),
    'due_at_utc_ms': _dateToStorage(input.dueAtUtc),
    'delivered_quantity_microunits': input.deliveredQuantity == null
        ? null
        : _quantityToMicrounits(input.deliveredQuantity!),
    'received_at_utc_ms': _optionalDateToStorage(input.receivedAtUtc),
    'document_id': input.documentId,
    'contact_id': input.contactId,
    'shortage_note': input.shortageNote,
    'damage_note': input.damageNote,
    'over_delivery_confirmed': overDeliveryConfirmed ? 1 : 0,
    'reminder_enabled': input.reminderEnabled ? 1 : 0,
    'created_at_utc_ms': _dateToStorage(createdAt),
    'updated_at_utc_ms': _dateToStorage(updatedAt),
  };
}

MaterialDelivery _deliveryFromRow(Map<String, Object?> row) {
  final delivered = row['delivered_quantity_microunits'] as int?;
  return MaterialDelivery(
    id: row['id']! as String,
    input: MaterialDeliveryInput(
      projectId: row['project_id']! as String,
      materialId: row['material_id']! as String,
      expectedQuantity: _quantityFromMicrounits(
        row['expected_quantity_microunits']! as int,
      ),
      dueAt: _date(row['due_at_utc_ms']),
      deliveredQuantity: delivered == null
          ? null
          : _quantityFromMicrounits(delivered),
      receivedAt: _optionalDate(row['received_at_utc_ms']),
      documentId: row['document_id'] as String?,
      contactId: row['contact_id'] as String?,
      shortageNote: row['shortage_note'] as String?,
      damageNote: row['damage_note'] as String?,
      overDeliveryConfirmed: row['over_delivery_confirmed'] == 1,
      reminderEnabled: row['reminder_enabled'] == 1,
    ),
    createdAt: _date(row['created_at_utc_ms']),
    updatedAt: _date(row['updated_at_utc_ms']),
  );
}

Map<String, Object?> _returnRow({
  required String id,
  required MaterialReturnInput input,
  required DateTime createdAt,
  required DateTime updatedAt,
}) {
  return <String, Object?>{
    'id': id,
    'project_id': input.projectId,
    'material_id': input.materialId,
    'quantity_microunits': _quantityToMicrounits(input.quantity),
    'deadline_utc_ms': _dateToStorage(input.deadlineUtc),
    'expected_refund_minor_units': input.expectedRefund?.minorUnits,
    'currency_code': input.expectedRefund?.currencyCode,
    'receipt_required': input.receiptRequired ? 1 : 0,
    'receipt_document_id': input.receiptDocumentId,
    'completed_at_utc_ms': _optionalDateToStorage(input.completedAtUtc),
    'actual_refund_minor_units': input.actualRefund?.minorUnits,
    'reminder_enabled': input.reminderEnabled ? 1 : 0,
    'note': input.note,
    'created_at_utc_ms': _dateToStorage(createdAt),
    'updated_at_utc_ms': _dateToStorage(updatedAt),
  };
}

MaterialReturn _returnFromRow(Map<String, Object?> row) {
  final expected = row['expected_refund_minor_units'] as int?;
  final actual = row['actual_refund_minor_units'] as int?;
  final currency = row['currency_code'] as String?;
  return MaterialReturn(
    id: row['id']! as String,
    input: MaterialReturnInput(
      projectId: row['project_id']! as String,
      materialId: row['material_id']! as String,
      quantity: _quantityFromMicrounits(row['quantity_microunits']! as int),
      deadline: _date(row['deadline_utc_ms']),
      expectedRefund: expected == null
          ? null
          : Money(minorUnits: expected, currencyCode: currency!),
      receiptRequired: row['receipt_required'] == 1,
      receiptDocumentId: row['receipt_document_id'] as String?,
      completedAt: _optionalDate(row['completed_at_utc_ms']),
      actualRefund: actual == null
          ? null
          : Money(minorUnits: actual, currencyCode: currency!),
      reminderEnabled: row['reminder_enabled'] == 1,
      note: row['note'] as String?,
    ),
    createdAt: _date(row['created_at_utc_ms']),
    updatedAt: _date(row['updated_at_utc_ms']),
  );
}

String _statusToStorage(MaterialStatus value) => switch (value) {
  MaterialStatus.planned => 'planned',
  MaterialStatus.ordered => 'ordered',
  MaterialStatus.partiallyDelivered => 'partially_delivered',
  MaterialStatus.delivered => 'delivered',
  MaterialStatus.delayed => 'delayed',
  MaterialStatus.returned => 'returned',
};

int _quantityToMicrounits(MaterialQuantity value) {
  final multiplier = _pow10(6 - value.scale);
  final result = BigInt.from(value.unscaledValue) * multiplier;
  if (result > BigInt.from(9223372036854775807)) {
    throw RangeError('Quantity must fit SQLite int64');
  }
  return result.toInt();
}

MaterialQuantity _quantityFromMicrounits(int value) {
  return MaterialQuantity(unscaledValue: value, scale: 6).normalized();
}

BigInt _pow10(int exponent) {
  var value = BigInt.one;
  for (var index = 0; index < exponent; index++) {
    value *= BigInt.from(10);
  }
  return value;
}

int _dateToStorage(DateTime value) {
  return DatabaseValueCodec.dateTimeToUtcMilliseconds(value);
}

int? _optionalDateToStorage(DateTime? value) {
  return value == null ? null : _dateToStorage(value);
}

DateTime _date(Object? value) {
  return DatabaseValueCodec.utcMillisecondsToDateTime(value! as int);
}

DateTime? _optionalDate(Object? value) {
  return value == null ? null : _date(value);
}

String _escapeLike(String value) {
  return value
      .replaceAll('\\', '\\\\')
      .replaceAll('%', '\\%')
      .replaceAll('_', '\\_');
}
