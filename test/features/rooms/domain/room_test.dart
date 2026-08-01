import 'package:budowapro/features/costs/domain/cost_entry.dart';
import 'package:budowapro/features/costs/domain/money.dart';
import 'package:budowapro/features/rooms/domain/room.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validates dimensions and keeps room money non-negative', () {
    final input = RoomInput(
      projectId: 'project-1',
      name: '  Kuchnia  ',
      floorLabel: ' Parter ',
      standard: RoomStandard.elevated,
      dimensions: RoomDimensions(
        lengthMillimeters: 4200,
        widthMillimeters: 3100,
        heightMillimeters: 2700,
      ),
      plannedBudget: Money(minorUnits: 4500000, currencyCode: 'PLN'),
    );

    expect(input.name, 'Kuchnia');
    expect(input.floorLabel, 'Parter');
    expect(input.dimensions!.areaSquareMillimeters, 13020000);
    expect(() => RoomDimensions(lengthMillimeters: 0), throwsRangeError);
    expect(
      () => RoomInput(
        projectId: 'project-1',
        name: 'Kuchnia',
        standard: RoomStandard.standard,
        plannedBudget: Money(minorUnits: -1, currencyCode: 'PLN'),
      ),
      throwsRangeError,
    );
  });

  test('calculates a selected variant with waste using half-up rounding', () {
    final choice = RoomChoice(
      id: 'choice-1',
      input: RoomChoiceInput(
        projectId: 'project-1',
        roomId: 'room-1',
        title: 'Plytki podlogowe',
        quantity: DecimalQuantity(unscaledValue: 25, scale: 1),
        unit: 'm2',
        wasteBasisPoints: 1000,
      ),
      variants: <RoomChoiceVariant>[
        RoomChoiceVariant(
          id: 'variant-1',
          choiceId: 'choice-1',
          input: RoomChoiceVariantInput(
            projectId: 'project-1',
            label: 'Gres A',
            unitGrossPrice: Money(minorUnits: 1234, currencyCode: 'PLN'),
          ),
          createdAt: DateTime.utc(2026, 7, 31),
          updatedAt: DateTime.utc(2026, 7, 31),
        ),
      ],
      status: RoomChoiceStatus.selected,
      selectedVariantId: 'variant-1',
      createdAt: DateTime.utc(2026, 7, 31),
      updatedAt: DateTime.utc(2026, 7, 31),
    );

    expect(choice.estimatedGross?.minorUnits, 3394);
    expect(choice.estimatedQuantityUnscaled, BigInt.from(275));
    expect(choice.estimatedQuantityScale, 2);
  });

  test('rejects a selected variant outside the choice', () {
    expect(
      () => RoomChoice(
        id: 'choice-1',
        input: RoomChoiceInput(
          projectId: 'project-1',
          roomId: 'room-1',
          title: 'Armatura',
        ),
        variants: const <RoomChoiceVariant>[],
        status: RoomChoiceStatus.selected,
        selectedVariantId: 'missing',
        createdAt: DateTime.utc(2026, 7, 31),
        updatedAt: DateTime.utc(2026, 7, 31),
      ),
      throwsArgumentError,
    );
  });
}
