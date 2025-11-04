
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/features/home/home_page.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  _TermsAndConditionsPageState createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _accepted = false;

  void _onContinue() async {
    if (_accepted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('accepted_terms', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''
Last updated: July 26, 2024

Please read these terms and conditions carefully before using Our Service.

Interpretation and Definitions
==============================

Interpretation
--------------

The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.

Definitions
-----------

For the purposes of these Terms and Conditions:

*   **"Application"** means the software program provided by the Company downloaded by You on any electronic device, named Law Genie.

*   **"Company"** (referred to as either "the Company", "We", "Us" or "Our" in this Agreement) refers to Law Genie.

*   **"Country"** refers to: Pakistan

*   **"Service"** refers to the Application.

*   **"Terms and Conditions"** (also referred as "Terms") mean these Terms and Conditions that form the entire agreement between You and the Company regarding the use of the Service.

*   **"You"** means the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.

Acknowledgment
==============

These are the Terms and Conditions governing the use of this Service and the agreement that operates between You and the Company. These Terms and Conditions set out the rights and obligations of all users regarding the use of the Service.

Your access to and use of the Service is conditioned on Your acceptance of and compliance with these Terms and Conditions. These Terms and Conditions apply to all visitors, users and others who access or use the Service.

By accessing or using the Service You agree to be bound by these Terms and Conditions. If You disagree with any part of these Terms and Conditions then You may not access the Service.

Your access to and use of the Service is also conditioned on Your acceptance of and compliance with the Privacy Policy of the Company. Our Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your personal information when You use the Application or the Website and tells You about Your privacy rights and how the law protects You. Please read Our Privacy Policy carefully before using Our Service.

Termination
===========

We may terminate or suspend Your access immediately, without prior notice or liability, for any reason whatsoever, including without limitation if You breach these Terms and Conditions.

Upon termination, Your right to use the Service will cease immediately.

Governing Law
=============

The laws of the Country, excluding its conflicts of law rules, shall govern this Terms and Your use of the Application. Your use of the Application may also be subject to other local, state, national, or international laws.

Disputes Resolution
===================

If You have any concern or dispute about the Service, You agree to first try to resolve the dispute informally by contacting the Company.

Changes to These Terms and Conditions
=====================================

We reserve the right, at Our sole discretion, to modify or replace these Terms at any time. If a revision is material We will make reasonable efforts to provide at least 30 days' notice prior to any new terms taking effect. What constitutes a material change will be determined at Our sole discretion.

By continuing to access or use Our Service after those revisions become effective, You agree to be bound by the revised terms. If You do not agree to the new terms, in whole or in part, please stop using the website and the Service.

Contact Us
==========

If you have any questions about these Terms and Conditions, You can contact us:

*   By email: syedkashifhussain9211@gmail.com
                  ''',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _accepted,
                  onChanged: (value) {
                    setState(() {
                      _accepted = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text('I have read and agree to the Terms and Conditions.'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _accepted ? _onContinue : null,
              child: const Center(child: Text('Continue')),
            ),
          ],
        ),
      ),
    );
  }
}
