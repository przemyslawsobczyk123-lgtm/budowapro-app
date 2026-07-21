import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/features/contacts/domain/contact.dart';
import 'package:budowapro/features/contacts/domain/contact_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:sqflite/sqflite.dart';

final class SqliteContactRepository implements ContactRepository {
  factory SqliteContactRepository({
    required AppDatabase database,
    required String Function() idGenerator,
    required DateTime Function() utcNow,
  }) => SqliteContactRepository._(database, idGenerator, utcNow);

  const SqliteContactRepository._(
    this._database,
    this._idGenerator,
    this._utcNow,
  );

  final AppDatabase _database;
  final String Function() _idGenerator;
  final DateTime Function() _utcNow;

  @override
  Future<Contact> create({
    required String projectId,
    required ContactDraft draft,
  }) {
    return _database.transaction<Contact>((transaction) async {
      final now = _utcNow().toUtc();
      final contact = Contact(
        id: _idGenerator(),
        projectId: projectId,
        draft: draft,
        createdAt: now,
        updatedAt: now,
      );
      await transaction.insert(
        AppDatabase.contactsTable,
        _contactToRow(contact),
      );
      await _replaceRelations(transaction, contact);
      return contact;
    });
  }

  @override
  Future<Contact> update({
    required String projectId,
    required String contactId,
    required ContactDraft draft,
  }) {
    return _database.transaction<Contact>((transaction) async {
      final existing = await _findById(transaction, projectId, contactId);
      if (existing == null) throw const ContactNotFoundException();
      final updated = Contact(
        id: existing.id,
        projectId: existing.projectId,
        draft: draft,
        isArchived: existing.isArchived,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
      );
      await transaction.update(
        AppDatabase.contactsTable,
        _contactToRow(updated),
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, contactId],
      );
      await _replaceRelations(transaction, updated);
      return updated;
    });
  }

  @override
  Future<Contact?> findById({
    required String projectId,
    required String contactId,
  }) async {
    return _findById(await _database.open(), projectId, contactId);
  }

  @override
  Future<Page<Contact>> list(ContactQuery query, PageRequest request) async {
    final database = await _database.open();
    final filter = _buildFilter(query);
    final countRows = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM ${AppDatabase.contactsTable} c '
      'WHERE ${filter.where}',
      filter.arguments,
    );
    final rows = await database.rawQuery(
      'SELECT c.* FROM ${AppDatabase.contactsTable} c '
      'WHERE ${filter.where} '
      'ORDER BY c.display_name COLLATE NOCASE ASC, c.id ASC '
      'LIMIT ? OFFSET ?',
      <Object?>[...filter.arguments, request.limit, request.offset],
    );
    return Page<Contact>(
      items: await _contactsFromRows(database, rows),
      totalCount: countRows.single['total']! as int,
      request: request,
    );
  }

  @override
  Future<Contact> setArchived({
    required String projectId,
    required String contactId,
    required bool isArchived,
  }) {
    return _database.transaction<Contact>((transaction) async {
      final existing = await _findById(transaction, projectId, contactId);
      if (existing == null) throw const ContactNotFoundException();
      final updated = Contact(
        id: existing.id,
        projectId: existing.projectId,
        draft: existing.draft,
        isArchived: isArchived,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
      );
      await transaction.update(
        AppDatabase.contactsTable,
        _contactToRow(updated),
        where: 'project_id = ? AND id = ?',
        whereArgs: <Object?>[projectId, contactId],
      );
      return updated;
    });
  }

  @override
  Future<void> delete({required String projectId, required String contactId}) {
    return _database.transaction<void>((transaction) async {
      final existing = await _findById(transaction, projectId, contactId);
      if (existing == null) throw const ContactNotFoundException();
      try {
        await transaction.delete(
          AppDatabase.contactsTable,
          where: 'project_id = ? AND id = ?',
          whereArgs: <Object?>[projectId, contactId],
        );
      } on DatabaseException catch (error, stackTrace) {
        final visits = await transaction.rawQuery(
          'SELECT COUNT(*) AS total FROM ${AppDatabase.siteVisitsTable} '
          'WHERE project_id = ? AND contact_id = ?',
          <Object?>[projectId, contactId],
        );
        if (visits.single['total']! as int > 0) {
          throw const ContactInUseException();
        }
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
  }
}

Future<Contact?> _findById(
  DatabaseExecutor executor,
  String projectId,
  String contactId,
) async {
  final rows = await executor.query(
    AppDatabase.contactsTable,
    where: 'project_id = ? AND id = ?',
    whereArgs: <Object?>[projectId, contactId],
    limit: 1,
  );
  if (rows.isEmpty) return null;
  return (await _contactsFromRows(executor, rows)).single;
}

Future<List<Contact>> _contactsFromRows(
  DatabaseExecutor executor,
  List<Map<String, Object?>> rows,
) async {
  if (rows.isEmpty) return const <Contact>[];
  final projectId = rows.first['project_id']! as String;
  final ids = rows.map((row) => row['id']! as String).toList(growable: false);
  final placeholders = List<String>.filled(ids.length, '?').join(',');
  final relationArguments = <Object?>[projectId, ...ids];
  final roleRows = await executor.query(
    AppDatabase.contactRolesTable,
    where: 'project_id = ? AND contact_id IN ($placeholders)',
    whereArgs: relationArguments,
    orderBy: 'contact_id ASC, role ASC',
  );
  final stageRows = await executor.query(
    AppDatabase.contactStageAssignmentsTable,
    where: 'project_id = ? AND contact_id IN ($placeholders)',
    whereArgs: relationArguments,
    orderBy: 'contact_id ASC, stage_id ASC',
  );
  final roles = <String, Set<ContactRole>>{};
  for (final row in roleRows) {
    (roles[row['contact_id']! as String] ??= <ContactRole>{}).add(
      _roleFromStorage(row['role']! as String),
    );
  }
  final stageIds = <String, Set<String>>{};
  for (final row in stageRows) {
    (stageIds[row['contact_id']! as String] ??= <String>{}).add(
      row['stage_id']! as String,
    );
  }
  return rows
      .map((row) {
        final id = row['id']! as String;
        return Contact(
          id: id,
          projectId: row['project_id']! as String,
          draft: ContactDraft(
            displayName: row['display_name']! as String,
            kind: ContactKind.values.byName(row['kind']! as String),
            roles: roles[id] ?? const <ContactRole>{ContactRole.other},
            stageIds: stageIds[id] ?? const <String>{},
            phone: row['phone'] as String?,
            email: row['email'] as String?,
            taxId: row['tax_id'] as String?,
            note: row['note'] as String?,
            rating: row['rating'] as int?,
          ),
          isArchived: row['is_archived'] == 1,
          createdAt: _fromStorage(row['created_at_utc_ms']! as int),
          updatedAt: _fromStorage(row['updated_at_utc_ms']! as int),
        );
      })
      .toList(growable: false);
}

Future<void> _replaceRelations(
  DatabaseExecutor executor,
  Contact contact,
) async {
  await executor.delete(
    AppDatabase.contactRolesTable,
    where: 'project_id = ? AND contact_id = ?',
    whereArgs: <Object?>[contact.projectId, contact.id],
  );
  await executor.delete(
    AppDatabase.contactStageAssignmentsTable,
    where: 'project_id = ? AND contact_id = ?',
    whereArgs: <Object?>[contact.projectId, contact.id],
  );
  for (final role in contact.roles) {
    await executor.insert(AppDatabase.contactRolesTable, <String, Object?>{
      'project_id': contact.projectId,
      'contact_id': contact.id,
      'role': _roleToStorage(role),
    });
  }
  for (final stageId in contact.stageIds) {
    await executor.insert(
      AppDatabase.contactStageAssignmentsTable,
      <String, Object?>{
        'project_id': contact.projectId,
        'contact_id': contact.id,
        'stage_id': stageId,
      },
    );
  }
}

_SqlFilter _buildFilter(ContactQuery query) {
  final clauses = <String>['c.project_id = ?'];
  final arguments = <Object?>[query.projectId];
  if (!query.includeArchived) {
    clauses.add('c.is_archived = ?');
    arguments.add(0);
  }
  if (query.searchTerm != null) {
    final pattern = '%${_escapeLike(query.searchTerm!)}%';
    clauses.add(
      '(LOWER(c.display_name) LIKE ? ESCAPE \'\\\' '
      'OR LOWER(COALESCE(c.phone, \'\')) LIKE ? ESCAPE \'\\\' '
      'OR LOWER(COALESCE(c.email, \'\')) LIKE ? ESCAPE \'\\\' '
      'OR LOWER(COALESCE(c.tax_id, \'\')) LIKE ? ESCAPE \'\\\')',
    );
    arguments.addAll(<Object?>[pattern, pattern, pattern, pattern]);
  }
  if (query.role != null) {
    clauses.add(
      'EXISTS (SELECT 1 FROM ${AppDatabase.contactRolesTable} r '
      'WHERE r.project_id = c.project_id AND r.contact_id = c.id '
      'AND r.role = ?)',
    );
    arguments.add(_roleToStorage(query.role!));
  }
  if (query.stageId != null) {
    clauses.add(
      'EXISTS (SELECT 1 FROM ${AppDatabase.contactStageAssignmentsTable} s '
      'WHERE s.project_id = c.project_id AND s.contact_id = c.id '
      'AND s.stage_id = ?)',
    );
    arguments.add(query.stageId);
  }
  return _SqlFilter(clauses.join(' AND '), arguments);
}

Map<String, Object?> _contactToRow(Contact contact) => <String, Object?>{
  'id': contact.id,
  'project_id': contact.projectId,
  'display_name': contact.displayName,
  'kind': contact.kind.name,
  'phone': contact.phone,
  'email': contact.email,
  'tax_id': contact.taxId,
  'note': contact.note,
  'rating': contact.rating,
  'is_archived': contact.isArchived ? 1 : 0,
  'created_at_utc_ms': _toStorage(contact.createdAtUtc),
  'updated_at_utc_ms': _toStorage(contact.updatedAtUtc),
};

String _escapeLike(String value) => value
    .replaceAll('\\', '\\\\')
    .replaceAll('%', '\\%')
    .replaceAll('_', '\\_');

String _roleToStorage(ContactRole role) => switch (role) {
  ContactRole.generalContractor => 'general_contractor',
  ContactRole.siteManager => 'site_manager',
  ContactRole.heatingAndVentilation => 'heating_and_ventilation',
  _ => role.name,
};

ContactRole _roleFromStorage(String value) => switch (value) {
  'general_contractor' => ContactRole.generalContractor,
  'site_manager' => ContactRole.siteManager,
  'heating_and_ventilation' => ContactRole.heatingAndVentilation,
  _ => ContactRole.values.byName(value),
};

int _toStorage(DateTime value) =>
    DatabaseValueCodec.dateTimeToUtcMilliseconds(value);

DateTime _fromStorage(int value) =>
    DatabaseValueCodec.utcMillisecondsToDateTime(value);

final class _SqlFilter {
  const _SqlFilter(this.where, this.arguments);

  final String where;
  final List<Object?> arguments;
}
