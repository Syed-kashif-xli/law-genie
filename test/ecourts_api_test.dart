import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/services/ecourts_service.dart';

void main() {
  test('Verify e-Courts API Connectivity with Real CNR', () async {
    debugPrint = (String? message, {int? wrapWidth}) {
      print('[SERVICE LOG] $message');
    };

    final service = EcourtsService();
    final cnr = 'MP04010449982021';

    print('Testing CNR: $cnr');

    final result = await service.getCaseStatusByCnr(cnr);

    if (result != null) {
      print('SUCCESS: Case Found!');
      print('Title: ${result.title}');
      print('Status: ${result.status}');
      print('Next Hearing: ${result.nextHearingDate}');
      print('Court: ${result.court}');
      print('Acts: ${result.acts}');
      print('Extra Petitioners: ${result.extraPetitioners}');
      print('Extra Respondents: ${result.extraRespondents}');
      print('Hearing History Records: ${result.hearingHistory?.length}');
      print('Interim Orders: ${result.interimOrders?.length}');
      print('Transfer Records: ${result.transfers?.length}');
    } else {
      print('FAILURE: Could not fetch case status.');
    }

    expect(result, isNotNull);
  });
}
