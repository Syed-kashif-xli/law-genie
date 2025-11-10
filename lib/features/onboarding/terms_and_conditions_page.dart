import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms and Conditions',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A0B2E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '''
          **Terms and Conditions**

          Welcome to Law Genie!

          These terms and conditions outline the rules and regulations for the use of Law Genie's Application, located at [Your App Store URL].

          By accessing this app we assume you accept these terms and conditions. Do not continue to use Law Genie if you do not agree to take all of the terms and conditions stated on this page.

          The following terminology applies to these Terms and Conditions, Privacy Statement and Disclaimer Notice and all Agreements: “Client”, “You” and “Your” refers to you, the person log on this app and compliant to the Company’s terms and conditions. “The Company”, “Ourselves”, “We”, “Our” and “Us”, refers to our Company. “Party”, “Parties”, or “Us”, refers to both the Client and ourselves. All terms refer to the offer, acceptance and consideration of payment necessary to undertake the process of our assistance to the Client in the most appropriate manner for the express purpose of meeting the Client’s needs in respect of provision of the Company’s stated services, in accordance with and subject to, prevailing law of Netherlands. Any use of the above terminology or other words in the singular, plural, capitalization and/or he/she or they, are taken as interchangeable and therefore as referring to same.

          **Cookies**

          We employ the use of cookies. By accessing Law Genie, you agreed to use cookies in agreement with the Law Genie's Privacy Policy.

          Most interactive websites use cookies to let us retrieve the user’s details for each visit. Cookies are used by our app to enable the functionality of certain areas to make it easier for people visiting our app. Some of our affiliate/advertising partners may also use cookies.

          **License**

          Unless otherwise stated, Law Genie and/or its licensors own the intellectual property rights for all material on Law Genie. All intellectual property rights are reserved. You may access this from Law Genie for your own personal use subjected to restrictions set in these terms and conditions.

          You must not:
          * Republish material from Law Genie
          * Sell, rent or sub-license material from Law Genie
          * Reproduce, duplicate or copy material from Law Genie
          * Redistribute content from Law Genie

          This Agreement shall begin on the date hereof.

          Parts of this app offer an opportunity for users to post and exchange opinions and information in certain areas of the app. Law Genie does not filter, edit, publish or review Comments prior to their presence on the app. Comments do not reflect the views and opinions of Law Genie,its agents and/or affiliates. Comments reflect the views and opinions of the person who post their views and opinions. To the extent permitted by applicable laws, Law Genie shall not be liable for the Comments or for any liability, damages or expenses caused and/or suffered as a result of any use of and/or posting of and/or appearance of the Comments on this app.

          Law Genie reserves the right to monitor all Comments and to remove any Comments which can be considered inappropriate, offensive or causes breach of these Terms and Conditions.
          ''',
          style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}
