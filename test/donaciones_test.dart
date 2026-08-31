import 'package:dobre/models/app_config.dart';
import 'package:dobre/widgets/donaciones_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const donationsConfig = DonationsConfig(
    enabled: true,
    title: '¿Te resultó útil DoBre?',
    description: 'DoBre es gratuito e independiente.',
    cafeLink: 'https://mpago.la/1dBku5K',
    apoyoLink: 'https://mpago.la/161b7Ax',
    impulsoLink: 'https://mpago.la/185dDQH',
    customLink: 'https://link.mercadopago.com.ar/nanilabs',
  );

  testWidgets('DonacionesSheet displays all 4 options and responds to tap', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DonacionesSheet(donationsConfig: donationsConfig),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify title and description
    expect(find.text('¿Te resultó útil DoBre?'), findsOneWidget);
    expect(find.text('DoBre es gratuito e independiente.'), findsOneWidget);

    // Verify all 4 donation options are displayed
    expect(find.text('Café'), findsOneWidget);
    expect(find.text('Apoyo'), findsOneWidget);
    expect(find.text('Impulso'), findsOneWidget);
    expect(find.text('Otro monto'), findsOneWidget);

    // Verify badge texts
    expect(find.text('\$ 1.000'), findsOneWidget);
    expect(find.text('\$ 2.500'), findsOneWidget);
    expect(find.text('\$ 5.000'), findsOneWidget);
    expect(find.text('Monto libre'), findsOneWidget);

    // Verify tap on Café
    await tester.tap(find.text('Café'));
    await tester.pump();

    // Verify tap on Apoyo
    await tester.tap(find.text('Apoyo'));
    await tester.pump();

    // Verify tap on Impulso
    await tester.tap(find.text('Impulso'));
    await tester.pump();

    // Verify tap on Otro monto
    await tester.tap(find.text('Otro monto'));
    await tester.pump();
  });
}
