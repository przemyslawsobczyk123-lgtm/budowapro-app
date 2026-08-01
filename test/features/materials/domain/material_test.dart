import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/materials/domain/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compares and adds quantities without floating point', () {
    final oneAndHalf = MaterialQuantity(unscaledValue: 15, scale: 1);
    final two = MaterialQuantity(unscaledValue: 2, scale: 0);

    expect(oneAndHalf.compareTo(two), lessThan(0));
    expect((oneAndHalf + two).unscaledValue, 35);
    expect((oneAndHalf + two).scale, 1);
  });

  test('derives partial, delayed and delivered material states', () {
    final input = _input(orderedAt: DateTime.utc(2026, 7, 20));
    final partial = MaterialItem(
      id: 'material-1',
      input: input,
      deliveries: <MaterialDelivery>[
        _delivery(delivered: 4, dueAt: DateTime.utc(2026, 7, 25)),
      ],
      returns: const <MaterialReturn>[],
      createdAt: DateTime.utc(2026, 7, 20),
      updatedAt: DateTime.utc(2026, 7, 25),
    );
    expect(
      partial.statusAt(DateTime.utc(2026, 8, 1)),
      MaterialStatus.partiallyDelivered,
    );

    final delayed = MaterialItem(
      id: 'material-1',
      input: input,
      deliveries: <MaterialDelivery>[
        _delivery(dueAt: DateTime.utc(2026, 7, 25)),
      ],
      returns: const <MaterialReturn>[],
      createdAt: DateTime.utc(2026, 7, 20),
      updatedAt: DateTime.utc(2026, 7, 20),
    );
    expect(delayed.statusAt(DateTime.utc(2026, 8, 1)), MaterialStatus.delayed);

    final delivered = MaterialItem(
      id: 'material-1',
      input: input,
      deliveries: <MaterialDelivery>[
        _delivery(delivered: 10, dueAt: DateTime.utc(2026, 7, 25)),
      ],
      returns: const <MaterialReturn>[],
      createdAt: DateTime.utc(2026, 7, 20),
      updatedAt: DateTime.utc(2026, 7, 25),
    );
    expect(
      delivered.statusAt(DateTime.utc(2026, 8, 1)),
      MaterialStatus.delivered,
    );
  });

  test('marks a fully returned delivery and reports overdue return', () {
    final completed = MaterialReturn(
      id: 'return-1',
      input: MaterialReturnInput(
        projectId: 'project-1',
        materialId: 'material-1',
        quantity: MaterialQuantity(unscaledValue: 10, scale: 0),
        deadline: DateTime.utc(2026, 8, 5),
        expectedRefund: Money(minorUnits: 10000, currencyCode: 'PLN'),
        receiptRequired: true,
        completedAt: DateTime.utc(2026, 8, 4),
        actualRefund: Money(minorUnits: 10000, currencyCode: 'PLN'),
      ),
      createdAt: DateTime.utc(2026, 8, 1),
      updatedAt: DateTime.utc(2026, 8, 4),
    );
    final item = MaterialItem(
      id: 'material-1',
      input: _input(orderedAt: DateTime.utc(2026, 7, 20)),
      deliveries: <MaterialDelivery>[
        _delivery(delivered: 10, dueAt: DateTime.utc(2026, 7, 25)),
      ],
      returns: <MaterialReturn>[completed],
      createdAt: DateTime.utc(2026, 7, 20),
      updatedAt: DateTime.utc(2026, 8, 4),
    );

    expect(item.statusAt(DateTime.utc(2026, 8, 6)), MaterialStatus.returned);

    final pending = MaterialReturn(
      id: 'return-2',
      input: MaterialReturnInput(
        projectId: 'project-1',
        materialId: 'material-1',
        quantity: MaterialQuantity(unscaledValue: 1, scale: 0),
        deadline: DateTime.utc(2026, 8, 5),
        receiptRequired: false,
      ),
      createdAt: DateTime.utc(2026, 8, 1),
      updatedAt: DateTime.utc(2026, 8, 1),
    );
    expect(pending.isOverdueAt(DateTime.utc(2026, 8, 6)), isTrue);
  });

  test('rejects inconsistent received delivery data', () {
    expect(
      () => MaterialDeliveryInput(
        projectId: 'project-1',
        materialId: 'material-1',
        expectedQuantity: MaterialQuantity(unscaledValue: 10, scale: 0),
        dueAt: DateTime.utc(2026, 8, 2),
        deliveredQuantity: MaterialQuantity(unscaledValue: 9, scale: 0),
      ),
      throwsArgumentError,
    );
  });

  test('uses actual refund as the estimate when none was recorded', () {
    final refund = Money(minorUnits: 1250, currencyCode: 'PLN');

    final input = MaterialReturnInput(
      projectId: 'project-1',
      materialId: 'material-1',
      quantity: MaterialQuantity(unscaledValue: 1, scale: 0),
      deadline: DateTime.utc(2026, 8, 5),
      receiptRequired: false,
      completedAt: DateTime.utc(2026, 8, 4),
      actualRefund: refund,
    );

    expect(input.expectedRefund, refund);
    expect(input.actualRefund, refund);
  });
}

MaterialInput _input({DateTime? orderedAt}) => MaterialInput(
  projectId: 'project-1',
  name: 'Bloczek silikatowy',
  orderedQuantity: MaterialQuantity(unscaledValue: 10, scale: 0),
  unit: 'pal.',
  stageId: 'shell_open',
  roomId: 'room-1',
  orderedAt: orderedAt,
  orderedGross: Money(minorUnits: 10000, currencyCode: 'PLN'),
  storageLocation: 'Utwardzony plac przy bramie',
);

MaterialDelivery _delivery({int? delivered, required DateTime dueAt}) {
  return MaterialDelivery(
    id: 'delivery-${delivered ?? 0}-${dueAt.day}',
    input: MaterialDeliveryInput(
      projectId: 'project-1',
      materialId: 'material-1',
      expectedQuantity: MaterialQuantity(unscaledValue: 10, scale: 0),
      dueAt: dueAt,
      deliveredQuantity: delivered == null
          ? null
          : MaterialQuantity(unscaledValue: delivered, scale: 0),
      receivedAt: delivered == null ? null : dueAt,
    ),
    createdAt: DateTime.utc(2026, 7, 20),
    updatedAt: delivered == null ? DateTime.utc(2026, 7, 20) : dueAt,
  );
}
