import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suzuki_app/core/widgets/egyptian_license_plate.dart';
import 'package:suzuki_app/core/widgets/seat_counter_selector.dart';
import 'package:suzuki_app/core/widgets/suzuki_cabin_grid.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SingleChildScrollView(
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('EgyptianLicensePlate renders letters and numbers in RTL', (tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(
      const EgyptianLicensePlate(
        numbers: '٥ ٤ ٨ ٢',
        letters: 'ق ن ص',
      ),
    ));

    expect(find.text('مصر'), findsOneWidget);
    expect(find.text('EGYPT'), findsOneWidget);
    expect(find.text('٥ ٤ ٨ ٢'), findsOneWidget);
    expect(find.text('ق ن ص'), findsOneWidget);
  });

  testWidgets('SuzukiCabinGrid renders all 7 seats and driver area', (tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(
      SuzukiCabinGrid(
        seatStatuses: const {
          1: SeatStatus.available,
          2: SeatStatus.occupied,
          3: SeatStatus.available,
        },
        onSeatTapped: (_) {},
      ),
    ));

    expect(find.text('الكابتن'), findsOneWidget);
    expect(find.text('الكنبة الوسطانية'), findsOneWidget);
    expect(find.text('الكنبة الأخيرة'), findsOneWidget);
    expect(find.text('مقعد 1'), findsOneWidget);
    expect(find.text('مقعد 7'), findsOneWidget);
  });

  testWidgets('SeatCounterSelector renders mode options and counts', (tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(
      SeatCounterSelector(
        seatCount: 2,
        maxSeats: 5,
        pricePerSeat: 7,
        charterPrice: 60,
        selectedMode: RideMode.shared,
        onCountChanged: (_) {},
        onModeChanged: (_) {},
      ),
    ));

    expect(find.text('عايز كام كرسي؟'), findsOneWidget);
    expect(find.text('كرسي (مشترك)'), findsOneWidget);
    expect(find.text('العربية كلها (مخصوص)'), findsOneWidget);
    expect(find.text('14 ج.م'), findsNWidgets(2));
  });
}
