import '../features/bare_acts/models/bare_act.dart';

class BareActService {
  // Curated list of major Indian Acts with PDF links
  final List<BareAct> _allActs = [
    // Constitutional
    BareAct(
      id: 'const_01',
      title: 'Constitution of India',
      category: 'Constitutional Law',
      year: '1950',
      pdfUrl:
          'https://cdnbbsr.s3waas.gov.in/s380537a945c7aaa788ccfcdf1b99b5d8f/uploads/2024/07/20240716890312078.pdf',
    ),

    // Criminal Law
    BareAct(
      id: 'bns_2023',
      title: 'Bharatiya Nyaya Sanhita (BNS)',
      category: 'Criminal Law',
      year: '2023',
      pdfUrl:
          'https://www.mha.gov.in/sites/default/files/250883_english_01042024.pdf',
    ),
    BareAct(
      id: 'bnss_2023',
      title: 'Bharatiya Nagarik Suraksha Sanhita (BNSS)',
      category: 'Criminal Law',
      year: '2023',
      pdfUrl:
          'https://www.mha.gov.in/sites/default/files/250882_english_01042024.pdf',
    ),
    BareAct(
      id: 'bsa_2023',
      title: 'Bharatiya Sakshya Adhiniyam (BSA)',
      category: 'Criminal Law',
      year: '2023',
      pdfUrl:
          'https://www.mha.gov.in/sites/default/files/250884_english_01042024.pdf',
    ),
    BareAct(
      id: 'ipc_1860',
      title: 'Indian Penal Code (IPC)',
      category: 'Criminal Law',
      year: '1860',
      pdfUrl:
          'https://www.indiacode.nic.in/bitstream/123456789/2263/1/A1860-45.pdf',
    ),
    BareAct(
      id: 'crpc_1973',
      title: 'Code of Criminal Procedure (CrPC)',
      category: 'Criminal Law',
      year: '1973',
      pdfUrl:
          'https://www.indiacode.nic.in/bitstream/123456789/15272/1/the_code_of_criminal_procedure%2C_1973.pdf',
    ),
    BareAct(
      id: 'iea_1872',
      title: 'Indian Evidence Act',
      category: 'Criminal Law',
      year: '1872',
      pdfUrl:
          'https://www.indiacode.nic.in/bitstream/123456789/6819/1/indian_evidence_act_1872.pdf',
    ),

    // Civil Law
    BareAct(
      id: 'cpc_1908',
      title: 'Code of Civil Procedure (CPC)',
      category: 'Civil Law',
      year: '1908',
      pdfUrl:
          'https://www.indiacode.nic.in/bitstream/123456789/2191/1/A1908-05.pdf',
    ),
    BareAct(
      id: 'contract_1872',
      title: 'Indian Contract Act',
      category: 'Civil Law',
      year: '1872',
      pdfUrl:
          'https://www.indiacode.nic.in/bitstream/123456789/2187/1/A1872-09.pdf',
    ),
    BareAct(
      id: 'tpa_1882',
      title: 'Transfer of Property Act',
      category: 'Civil Law',
      year: '1882',
      pdfUrl:
          'https://www.indiacode.nic.in/bitstream/123456789/2338/1/A1882-04.pdf',
    ),

    // Family Law
    BareAct(
      id: 'hma_1955',
      title: 'Hindu Marriage Act',
      category: 'Family Law',
      year: '1955',
      pdfUrl:
          'https://www.indiacode.nic.in/bitstream/123456789/1560/1/195525.pdf',
    ),
    BareAct(
      id: 'sma_1954',
      title: 'Special Marriage Act',
      category: 'Family Law',
      year: '1954',
      pdfUrl:
          'https://www.indiacode.nic.in/bitstream/123456789/1387/1/195443.pdf',
    ),

    // Corporate & Tax
    BareAct(
      id: 'companies_2013',
      title: 'Companies Act',
      category: 'Corporate Law',
      year: '2013',
      pdfUrl: 'https://www.mca.gov.in/Ministry/pdf/CompaniesAct2013.pdf',
    ),
    BareAct(
      id: 'gst_2017',
      title: 'CGST Act',
      category: 'Tax Law',
      year: '2017',
      pdfUrl:
          'https://cbic-gst.gov.in/pdf/CGST-Act-Updated-upto-01-01-2022.pdf',
    ),

    // Other Important Acts
    BareAct(
      id: 'it_2000',
      title: 'Information Technology Act',
      category: 'Cyber Law',
      year: '2000',
      pdfUrl:
          'https://www.indiacode.nic.in/bitstream/123456789/13116/1/it_act_2000_updated.pdf',
    ),
    BareAct(
      id: 'rti_2005',
      title: 'Right to Information Act',
      category: 'Administrative Law',
      year: '2005',
      pdfUrl: 'https://rti.gov.in/rti-act.pdf',
    ),
    BareAct(
      id: 'pocso_2012',
      title: 'POCSO Act',
      category: 'Criminal Law',
      year: '2012',
      pdfUrl:
          'https://wcd.nic.in/sites/default/files/POCSO%20Act%2C%202012.pdf',
    ),
  ];

  Future<List<BareAct>> getAllActs() async {
    return _allActs;
  }

  Future<List<BareAct>> searchActs(String query) async {
    if (query.isEmpty) return _allActs;

    final q = query.toLowerCase();
    return _allActs
        .where((act) =>
            act.title.toLowerCase().contains(q) ||
            act.category.toLowerCase().contains(q) ||
            act.year.contains(q))
        .toList();
  }

  Future<List<BareAct>> getActsByCategory(String category) async {
    if (category == 'All') return _allActs;
    return _allActs.where((act) => act.category == category).toList();
  }

  List<String> getCategories() {
    return [
      'All',
      'Constitutional Law',
      'Criminal Law',
      'Civil Law',
      'Family Law',
      'Corporate Law',
      'Tax Law',
      'Cyber Law',
      'Administrative Law',
    ];
  }
}
