
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:myapp/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final timelineCollection = firestore.collection('timeline');

  final timelineEvents = [
    {
      "title": "FIR Filed",
      "description": "The First Information Report was filed at the local police station.",
      "date": "2023-01-15T00:00:00.000Z",
      "status": "completed",
      "icon": {"codePoint": 58494, "fontFamily": "MaterialIcons"}
    },
    {
      "title": "Investigation Started",
      "description": "The police have started their investigation into the case.",
      "date": "2023-01-20T00:00:00.000Z",
      "status": "completed",
      "icon": {"codePoint": 59547, "fontFamily": "MaterialIcons"}
    },
    {
      "title": "Evidence Collection",
      "description": "Relevant evidence is being collected by the investigation team.",
      "date": "2023-02-10T00:00:00.000Z",
      "status": "completed",
      "icon": {"codePoint": 58843, "fontFamily": "MaterialIcons"}
    },
    {
      "title": "Witnesses Interviewed",
      "description": "Key witnesses have been interviewed to gather more information.",
      "date": "2023-02-25T00:00:00.000Z",
      "status": "completed",
      "icon": {"codePoint": 59513, "fontFamily": "MaterialIcons"}
    },
    {
      "title": "Chargesheet Filed",
      "description": "The chargesheet has been filed in the court.",
      "date": "2023-03-15T00:00:00.000Z",
      "status": "completed",
      "icon": {"codePoint": 61448, "fontFamily": "MaterialIcons"}
    },
    {
      "title": "First Hearing",
      "description": "The first hearing of the case is scheduled.",
      "date": "2023-04-05T00:00:00.000Z",
      "status": "completed",
      "icon": {"codePoint": 61501, "fontFamily": "MaterialIcons"}
    },
    {
      "title": "Arguments Heard",
      "description": "The court has heard the arguments from both sides.",
      "date": "2023-04-20T00:00:00.000Z",
      "status": "ongoing",
      "icon": {"codePoint": 58949, "fontFamily": "MaterialIcons"}
    },
    {
      "title": "Judgment Reserved",
      "description": "The judgment in the case has been reserved.",
      "date": "2023-05-01T00:00:00.000Z",
      "status": "ongoing",
      "icon": {"codePoint": 59667, "fontFamily": "MaterialIcons"}
    },
    {
      "title": "Judgment Pronounced",
      "description": "The final judgment will be pronounced.",
      "date": "2023-05-10T00:00:00.000Z",
      "status": "upcoming",
      "icon": {"codePoint": 59518, "fontFamily": "MaterialIcons"}
    },
    {
      "title": "Next Hearing",
      "description": "The next hearing is scheduled for further proceedings.",
      "date": "2024-06-01T00:00:00.000Z",
      "status": "upcoming",
      "icon": {"codePoint": 58949, "fontFamily": "MaterialIcons"}
    }
  ];

  for (var event in timelineEvents) {
    await timelineCollection.add({
      'title': event['title'],
      'description': event['description'],
      'date': Timestamp.fromDate(DateTime.parse(event['date'] as String)),
      'status': event['status'],
      'icon': event['icon'],
    });
  }

  print('Database seeded successfully!');
}
