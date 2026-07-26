import 'dart:math';

import 'package:budowapro/core/database/app_database.dart';
import 'package:budowapro/core/database/database_value_codec.dart';
import 'package:budowapro/core/files/project_file_store.dart';
import 'package:budowapro/features/projects/domain/project.dart';
import 'package:budowapro/features/projects/domain/project_repository.dart';
import 'package:budowapro/shared/models/page.dart';
import 'package:sqflite/sqflite.dart';

typedef ProjectIdGenerator = String Function();
typedef UtcNow = DateTime Function();

final class SqliteProjectRepository implements ProjectRepository {
  factory SqliteProjectRepository({
    required AppDatabase database,
    required ProjectFileStorage fileStore,
    ProjectIdGenerator? idGenerator,
    UtcNow? utcNow,
  }) {
    return SqliteProjectRepository._(
      database,
      fileStore,
      idGenerator ?? _secureProjectId,
      utcNow ?? DateTime.now,
    );
  }

  const SqliteProjectRepository._(
    this._database,
    this._fileStore,
    this._idGenerator,
    this._utcNow,
  );

  static const String selectedProjectKey = 'selected_project_id';

  final AppDatabase _database;
  final ProjectFileStorage _fileStore;
  final ProjectIdGenerator _idGenerator;
  final UtcNow _utcNow;

  @override
  Future<Project> create(ProjectDraft draft) async {
    final timestamp = _utcNow();
    final project = Project(
      id: _idGenerator(),
      draft: draft,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await _database.transaction<void>((transaction) async {
      await transaction.insert(
        AppDatabase.projectsTable,
        _projectToRow(project),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await _writeSelectedProject(transaction, project.id);
    });
    return project;
  }

  @override
  Future<Project> update(String projectId, ProjectDraft draft) async {
    return _database.transaction<Project>((transaction) async {
      final existing = await _findById(transaction, projectId);
      if (existing == null) {
        throw const ProjectNotFoundException();
      }
      if (existing.currencyCode != draft.currencyCode &&
          await _countCostEntries(transaction, projectId) > 0) {
        throw const ProjectCurrencyLockedException();
      }
      final updated = Project(
        id: existing.id,
        draft: draft,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
        isArchived: existing.isArchived,
        templateVersion: existing.templateVersion,
      );
      await transaction.update(
        AppDatabase.projectsTable,
        _projectToRow(updated),
        where: 'id = ?',
        whereArgs: <Object?>[projectId],
      );
      return updated;
    });
  }

  @override
  Future<Project?> findById(String projectId) async {
    final database = await _database.open();
    return _findById(database, projectId);
  }

  @override
  Future<Page<Project>> list(
    PageRequest request, {
    bool includeArchived = false,
  }) async {
    final database = await _database.open();
    final where = includeArchived
        ? 'deletion_pending = ?'
        : 'is_archived = ? AND deletion_pending = ?';
    final whereArgs = includeArchived ? <Object?>[0] : <Object?>[0, 0];
    final countRows = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM ${AppDatabase.projectsTable}'
      ' WHERE $where',
      whereArgs,
    );
    final rows = await database.query(
      AppDatabase.projectsTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'updated_at_utc_ms DESC, id ASC',
      limit: request.limit,
      offset: request.offset,
    );
    return Page<Project>(
      items: rows.map(_projectFromRow),
      totalCount: countRows.single['total']! as int,
      request: request,
    );
  }

  @override
  Future<Project?> selected() async {
    final database = await _database.open();
    final metadata = await database.query(
      AppDatabase.metadataTable,
      columns: const <String>['value'],
      where: 'key = ?',
      whereArgs: <Object?>[selectedProjectKey],
      limit: 1,
    );
    if (metadata.isEmpty) {
      return null;
    }
    return _findById(
      database,
      metadata.single['value']! as String,
      activeOnly: true,
    );
  }

  @override
  Future<void> select(String projectId) async {
    await _database.transaction<void>((transaction) async {
      final project = await _findById(transaction, projectId, activeOnly: true);
      if (project == null) {
        throw const ProjectNotFoundException();
      }
      await _writeSelectedProject(transaction, projectId);
    });
  }

  @override
  Future<Project> setArchived(
    String projectId, {
    required bool isArchived,
  }) async {
    return _database.transaction<Project>((transaction) async {
      final existing = await _findById(transaction, projectId);
      if (existing == null) {
        throw const ProjectNotFoundException();
      }
      final updated = Project(
        id: existing.id,
        draft: existing.draft,
        createdAt: existing.createdAtUtc,
        updatedAt: _utcNow(),
        isArchived: isArchived,
        templateVersion: existing.templateVersion,
      );
      await transaction.update(
        AppDatabase.projectsTable,
        _projectToRow(updated),
        where: 'id = ?',
        whereArgs: <Object?>[projectId],
      );
      if (isArchived && await _isSelected(transaction, projectId)) {
        await _selectFallback(transaction, excludingProjectId: projectId);
      }
      return updated;
    });
  }

  @override
  Future<ProjectDeletionImpact> deletionImpact(String projectId) async {
    final database = await _database.open();
    final project = await _findById(database, projectId);
    if (project == null) {
      throw const ProjectNotFoundException();
    }
    return ProjectDeletionImpact(
      project: project,
      linkedFileCount: await _fileStore.countProjectFiles(projectId),
      linkedRecordCount: await _countProjectRecords(database, projectId),
    );
  }

  @override
  Future<void> delete(String projectId) async {
    await _database.transaction<void>((transaction) async {
      final existing = await _findById(transaction, projectId);
      if (existing == null) {
        throw const ProjectNotFoundException();
      }
      final changedRows = await transaction.update(
        AppDatabase.projectsTable,
        const <String, Object?>{'deletion_pending': 1},
        where: 'id = ? AND deletion_pending = ?',
        whereArgs: <Object?>[projectId, 0],
      );
      if (changedRows != 1) {
        throw StateError('Project deletion is already in progress');
      }
    });

    try {
      await _fileStore.deleteProjectFiles(projectId);
    } on Object catch (error, stackTrace) {
      await _resetPendingDeletion(projectId);
      Error.throwWithStackTrace(error, stackTrace);
    }

    await _completeDeletion(projectId);
  }

  Future<void> recoverPendingDeletions() async {
    final database = await _database.open();
    final rows = await database.query(
      AppDatabase.projectsTable,
      columns: const <String>['id'],
      where: 'deletion_pending = ?',
      whereArgs: const <Object?>[1],
      orderBy: 'updated_at_utc_ms ASC, id ASC',
    );

    for (final row in rows) {
      final projectId = row['id']! as String;
      try {
        await _fileStore.deleteProjectFiles(projectId);
      } on Object {
        await _resetPendingDeletion(projectId);
        continue;
      }
      await _completeDeletion(projectId);
    }
  }

  Future<void> _resetPendingDeletion(String projectId) {
    return _database.transaction<void>((transaction) async {
      await transaction.update(
        AppDatabase.projectsTable,
        const <String, Object?>{'deletion_pending': 0},
        where: 'id = ?',
        whereArgs: <Object?>[projectId],
      );
    });
  }

  Future<void> _completeDeletion(String projectId) {
    return _database.transaction<void>((transaction) async {
      final existing = await _findById(transaction, projectId);
      if (existing == null) {
        return;
      }
      await transaction.delete(
        AppDatabase.projectsTable,
        where: 'id = ?',
        whereArgs: <Object?>[projectId],
      );
      if (await _isSelected(transaction, projectId)) {
        await _selectFallback(transaction, excludingProjectId: projectId);
      }
    });
  }

  static Future<Project?> _findById(
    DatabaseExecutor executor,
    String projectId, {
    bool activeOnly = false,
  }) async {
    final rows = await executor.query(
      AppDatabase.projectsTable,
      where: activeOnly
          ? 'id = ? AND is_archived = ? AND deletion_pending = ?'
          : 'id = ?',
      whereArgs: activeOnly ? <Object?>[projectId, 0, 0] : <Object?>[projectId],
      limit: 1,
    );
    return rows.isEmpty ? null : _projectFromRow(rows.single);
  }

  static Future<int> _countCostEntries(
    DatabaseExecutor executor,
    String projectId,
  ) async {
    final rows = await executor.rawQuery(
      'SELECT COUNT(*) AS total FROM ${AppDatabase.costEntriesTable}'
      ' WHERE project_id = ?',
      <Object?>[projectId],
    );
    return rows.single['total']! as int;
  }

  static Future<int> _countProjectRecords(
    DatabaseExecutor executor,
    String projectId,
  ) async {
    final rows = await executor.rawQuery(
      '''
        SELECT
          (SELECT COUNT(*) FROM ${AppDatabase.costEntriesTable}
            WHERE project_id = ?) +
          (SELECT COUNT(*) FROM ${AppDatabase.projectStagesTable}
            WHERE project_id = ?) +
          (SELECT COUNT(*) FROM ${AppDatabase.checklistItemsTable}
            WHERE project_id = ?) +
          (SELECT COUNT(*) FROM ${AppDatabase.scheduleEventsTable}
            WHERE project_id = ?) +
          (SELECT COUNT(*) FROM ${AppDatabase.contactsTable}
            WHERE project_id = ?) +
          (SELECT COUNT(*) FROM ${AppDatabase.captureDraftsTable}
            WHERE project_id = ?) AS total
      ''',
      <Object?>[
        projectId,
        projectId,
        projectId,
        projectId,
        projectId,
        projectId,
      ],
    );
    return rows.single['total']! as int;
  }

  static Future<bool> _isSelected(
    DatabaseExecutor executor,
    String projectId,
  ) async {
    final rows = await executor.query(
      AppDatabase.metadataTable,
      columns: const <String>['key'],
      where: 'key = ? AND value = ?',
      whereArgs: <Object?>[selectedProjectKey, projectId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  static Future<void> _selectFallback(
    DatabaseExecutor executor, {
    required String excludingProjectId,
  }) async {
    final rows = await executor.query(
      AppDatabase.projectsTable,
      columns: const <String>['id'],
      where: 'id != ? AND is_archived = ? AND deletion_pending = ?',
      whereArgs: <Object?>[excludingProjectId, 0, 0],
      orderBy: 'updated_at_utc_ms DESC, id ASC',
      limit: 1,
    );
    if (rows.isEmpty) {
      await executor.delete(
        AppDatabase.metadataTable,
        where: 'key = ?',
        whereArgs: <Object?>[selectedProjectKey],
      );
      return;
    }
    await _writeSelectedProject(executor, rows.single['id']! as String);
  }

  static Future<void> _writeSelectedProject(
    DatabaseExecutor executor,
    String projectId,
  ) async {
    await executor.insert(AppDatabase.metadataTable, <String, Object?>{
      'key': selectedProjectKey,
      'value': projectId,
      'updated_at_utc_ms': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Map<String, Object?> _projectToRow(Project project) {
    return <String, Object?>{
      'id': project.id,
      'name': project.name,
      'location_label': project.locationLabel,
      'project_type': _projectTypeToStorage(project.type),
      'template_key': _templateToStorage(project.template),
      'template_version': project.templateVersion,
      'currency_code': project.currencyCode,
      'area_square_meters': project.areaSquareMeters,
      'planned_budget_minor_units': project.plannedBudgetMinorUnits,
      'planned_start_utc_ms': _dateToStorage(project.plannedStart),
      'planned_end_utc_ms': _dateToStorage(project.plannedEnd),
      'date_format': _dateFormatToStorage(project.dateFormat),
      'current_stage_key': _stageToLegacyStorage(project.currentStage),
      'current_stage_key_v2': _stageToStorage(project.currentStage),
      'is_archived': project.isArchived ? 1 : 0,
      'created_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
        project.createdAtUtc,
      ),
      'updated_at_utc_ms': DatabaseValueCodec.dateTimeToUtcMilliseconds(
        project.updatedAtUtc,
      ),
    };
  }

  static Project _projectFromRow(Map<String, Object?> row) {
    return Project(
      id: row['id']! as String,
      draft: ProjectDraft(
        name: row['name']! as String,
        locationLabel: row['location_label'] as String?,
        type: _projectTypeFromStorage(row['project_type']! as String),
        template: _templateFromStorage(row['template_key']! as String),
        currencyCode: row['currency_code']! as String,
        areaSquareMeters: row['area_square_meters'] as int?,
        plannedBudgetMinorUnits: row['planned_budget_minor_units'] as int?,
        plannedStart: _dateFromStorage(row['planned_start_utc_ms'] as int?),
        plannedEnd: _dateFromStorage(row['planned_end_utc_ms'] as int?),
        dateFormat: _dateFormatFromStorage(row['date_format']! as String),
        currentStage: _stageFromStorage(
          row['current_stage_key_v2'] as String? ??
              row['current_stage_key']! as String,
        ),
      ),
      createdAt: DatabaseValueCodec.utcMillisecondsToDateTime(
        row['created_at_utc_ms']! as int,
      ),
      updatedAt: DatabaseValueCodec.utcMillisecondsToDateTime(
        row['updated_at_utc_ms']! as int,
      ),
      isArchived: row['is_archived']! as int == 1,
      templateVersion: row['template_version']! as int,
    );
  }

  static int? _dateToStorage(DateTime? value) {
    return value == null
        ? null
        : DatabaseValueCodec.dateTimeToUtcMilliseconds(value);
  }

  static DateTime? _dateFromStorage(int? value) {
    return value == null
        ? null
        : DatabaseValueCodec.utcMillisecondsToDateTime(value);
  }

  static String _projectTypeToStorage(ProjectType value) => switch (value) {
    ProjectType.houseBuild => 'house_build',
    ProjectType.houseRenovation => 'house_renovation',
    ProjectType.apartmentRenovation => 'apartment_renovation',
  };

  static ProjectType _projectTypeFromStorage(String value) => switch (value) {
    'house_build' => ProjectType.houseBuild,
    'house_renovation' => ProjectType.houseRenovation,
    'apartment_renovation' => ProjectType.apartmentRenovation,
    _ => throw FormatException('Unsupported project type'),
  };

  static String _templateToStorage(ProjectTemplate value) => switch (value) {
    ProjectTemplate.houseConstruction => 'build_house',
    ProjectTemplate.renovation => 'renovation',
  };

  static ProjectTemplate _templateFromStorage(String value) => switch (value) {
    'build_house' => ProjectTemplate.houseConstruction,
    'renovation' => ProjectTemplate.renovation,
    _ => throw FormatException('Unsupported project template'),
  };

  static String _dateFormatToStorage(ProjectDateFormat value) =>
      switch (value) {
        ProjectDateFormat.dayMonthYear => 'day_month_year',
        ProjectDateFormat.yearMonthDay => 'year_month_day',
      };

  static ProjectDateFormat _dateFormatFromStorage(String value) =>
      switch (value) {
        'day_month_year' => ProjectDateFormat.dayMonthYear,
        'year_month_day' => ProjectDateFormat.yearMonthDay,
        _ => throw FormatException('Unsupported project date format'),
      };

  static String _stageToStorage(ProjectStageKey value) => switch (value) {
    ProjectStageKey.planning => 'planning',
    ProjectStageKey.formalities => 'formalities',
    ProjectStageKey.sitePreparation => 'site_preparation',
    ProjectStageKey.stateZero => 'state_zero',
    ProjectStageKey.shellOpen => 'shell_open',
    ProjectStageKey.shellClosed => 'shell_closed',
    ProjectStageKey.demolition => 'demolition',
    ProjectStageKey.installations => 'installations',
    ProjectStageKey.plaster => 'plaster',
    ProjectStageKey.finishing => 'finishing',
    ProjectStageKey.handover => 'handover',
  };

  static String _stageToLegacyStorage(ProjectStageKey value) =>
      value == ProjectStageKey.sitePreparation
      ? 'formalities'
      : _stageToStorage(value);

  static ProjectStageKey _stageFromStorage(String value) => switch (value) {
    'planning' => ProjectStageKey.planning,
    'formalities' => ProjectStageKey.formalities,
    'site_preparation' => ProjectStageKey.sitePreparation,
    'state_zero' => ProjectStageKey.stateZero,
    'shell_open' => ProjectStageKey.shellOpen,
    'shell_closed' => ProjectStageKey.shellClosed,
    'demolition' => ProjectStageKey.demolition,
    'installations' => ProjectStageKey.installations,
    'plaster' => ProjectStageKey.plaster,
    'finishing' => ProjectStageKey.finishing,
    'handover' => ProjectStageKey.handover,
    _ => throw FormatException('Unsupported project stage'),
  };

  static String _secureProjectId() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List<String>.generate(
      24,
      (_) => alphabet[random.nextInt(alphabet.length)],
      growable: false,
    ).join();
  }
}
