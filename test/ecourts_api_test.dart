import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/services/ecourts_service.dart';

void main() {
  test('Verify e-Courts API Connectivity with Real CNR', () async {
    debugPrint = (String? message, {int? wrapWidth}) {
      // ignore: avoid_print
      print('[SERVICE LOG] $message');
    };

    final service = EcourtsService();
    final cnr = 'MP04010449982021';

    debugPrint('Testing CNR: $cnr');

    final result = await service.getCaseStatusByCnr(cnr);

    if (result != null) {
      debugPrint('SUCCESS: Case Found!');
      debugPrint('Title: ${result.title}');
      debugPrint('Status: ${result.status}');
      debugPrint('Next Hearing: ${result.nextHearingDate}');
      debugPrint('Court: ${result.court}');
      debugPrint('Filing Date: ${result.filingDate}');
      debugPrint('Filing Number: ${result.filingNumber}');
      debugPrint('Nature of Disposal: ${result.natureOfDisposal}');
      debugPrint('Court Number: ${result.courtNumber}');
      debugPrint('Judge Designation: ${result.judgeDesignation}');
      debugPrint('Acts: ${result.acts}');
      debugPrint('Extra Petitioners: ${result.extraPetitioners}');
      debugPrint('Extra Respondents: ${result.extraRespondents}');
      debugPrint('Hearing History Records: ${result.hearingHistory?.length}');
      if (result.hearingHistory != null && result.hearingHistory!.isNotEmpty) {
        final firstH = result.hearingHistory!.first;
        debugPrint(
            'First History Item Business Params: ${firstH.businessParams}');
      }
      debugPrint('Interim Orders: ${result.interimOrders?.length}');
      debugPrint('Transfer Records: ${result.transfers?.length}');

      if (result.hearingHistory != null && result.hearingHistory!.isNotEmpty) {
        final firstH = result.hearingHistory!.first;
        if (firstH.businessParams != null) {
          debugPrint(
              'Testing Business Details for Date: ${firstH.hearingDate}');
          final businessContent =
              await service.getBusinessDetails(firstH.businessParams!);
          debugPrint(
              'Business Details Content: ${businessContent?.substring(0, (businessContent.length > 200 ? 200 : businessContent.length))}...');
          expect(businessContent, isNotNull);
        }
      }
    } else {
      debugPrint('FAILURE: Could not fetch case status.');
    }

    expect(result, isNotNull);
  });
}
