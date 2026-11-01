import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Search',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const StudentSearchPage(),
    );
  }
}

class StudentSearchPage extends StatefulWidget {
  const StudentSearchPage({super.key});

  @override
  State<StudentSearchPage> createState() => _StudentSearchPageState();
}

class _StudentSearchPageState extends State<StudentSearchPage> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> students = [];

  bool isLoading = false;
  bool searched = false;
  String errorMessage = '';

  Future<void> searchStudents() async {
    String searchText = searchController.text.trim().toLowerCase();

    if (searchText.isEmpty) {
      setState(() {
        students = [];
        searched = false;
        errorMessage = 'Please enter a name or register number.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      searched = true;
      errorMessage = '';
      students = [];
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('students')
          .get();

      List<Map<String, dynamic>> results = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        String name = (data['name'] ?? '').toString().toLowerCase();

        String registerNumber = (data['registerNumber'] ?? '')
            .toString()
            .toLowerCase();

        if (name.contains(searchText) || registerNumber.contains(searchText)) {
          results.add(data);
        }
      }

      setState(() {
        students = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error retrieving data: $e';
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FA),
      appBar: AppBar(
        title: const Text(
          'Student Information',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.school, size: 65, color: Colors.indigo),
                const SizedBox(height: 12),

                const Text(
                  'Search Student Records',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Find student details using name or register number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: searchController,
                  onSubmitted: (_) => searchStudents(),
                  decoration: InputDecoration(
                    hintText: 'Enter name or register number',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                ElevatedButton.icon(
                  onPressed: isLoading ? null : searchStudents,
                  icon: const Icon(Icons.search),
                  label: const Text('Search Student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                ),

                const SizedBox(height: 25),

                if (isLoading) const Center(child: CircularProgressIndicator()),

                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),

                if (!isLoading &&
                    searched &&
                    students.isEmpty &&
                    errorMessage.isEmpty)
                  const Text(
                    'No student records found.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),

                if (!isLoading && students.isNotEmpty)
                  Text(
                    '${students.length} student record(s) found',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 12),

                ...students.map((student) {
                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.account_circle,
                            size: 45,
                            color: Colors.indigo,
                          ),
                          const SizedBox(height: 10),

                          Text(
                            student['name'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Divider(),

                          Text(
                            'Register Number: ${student['registerNumber'] ?? 'N/A'}',
                          ),
                          const SizedBox(height: 8),

                          Text('Department: ${student['department'] ?? 'N/A'}'),
                          const SizedBox(height: 8),

                          Text('Email: ${student['email'] ?? 'N/A'}'),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
