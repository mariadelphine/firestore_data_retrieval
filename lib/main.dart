import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

// Main Application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management System',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const StudentPage(),
    );
  }
}

// Student Management Page
class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final nameController = TextEditingController();
  final regController = TextEditingController();
  final deptController = TextEditingController();
  final emailController = TextEditingController();

  final CollectionReference students = FirebaseFirestore.instance.collection(
    'students',
  );

  // Add Student to Firestore
  Future<void> addStudent() async {
    if (nameController.text.trim().isEmpty ||
        regController.text.trim().isEmpty ||
        deptController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      await students.add({
        'name': nameController.text.trim(),
        'registerNumber': regController.text.trim(),
        'department': deptController.text.trim(),
        'email': emailController.text.trim(),
      });

      nameController.clear();
      regController.clear();
      deptController.clear();
      emailController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Delete Student from Firestore
  Future<void> deleteStudent(String id) async {
    try {
      await students.doc(id).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Edit Student Details
  Future<void> editStudent(String id, Map<String, dynamic> data) async {
    final editName = TextEditingController(text: data['name'] ?? '');
    final editReg = TextEditingController(text: data['registerNumber'] ?? '');
    final editDept = TextEditingController(text: data['department'] ?? '');
    final editEmail = TextEditingController(text: data['email'] ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Student Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editName,
                  decoration: const InputDecoration(labelText: 'Student Name'),
                ),
                TextField(
                  controller: editReg,
                  decoration: const InputDecoration(
                    labelText: 'Register Number',
                  ),
                ),
                TextField(
                  controller: editDept,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
                TextField(
                  controller: editEmail,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editName.text.trim().isEmpty ||
                    editReg.text.trim().isEmpty ||
                    editDept.text.trim().isEmpty ||
                    editEmail.text.trim().isEmpty) {
                  return;
                }

                try {
                  await students.doc(id).update({
                    'name': editName.text.trim(),
                    'registerNumber': editReg.text.trim(),
                    'department': editDept.text.trim(),
                    'email': editEmail.text.trim(),
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    editName.dispose();
    editReg.dispose();
    editDept.dispose();
    editEmail.dispose();
  }

  @override
  void dispose() {
    nameController.dispose();
    regController.dispose();
    deptController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // Application UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management System'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Student Details',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Student Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Register Number
            TextField(
              controller: regController,
              decoration: const InputDecoration(
                labelText: 'Register Number',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Department
            TextField(
              controller: deptController,
              decoration: const InputDecoration(
                labelText: 'Department',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Email
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            // Add Button
            ElevatedButton.icon(
              onPressed: addStudent,
              icon: const Icon(Icons.add),
              label: const Text('Add Student'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              'Saved Student Records',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // Retrieve Students from Firestore
            StreamBuilder<QuerySnapshot>(
              stream: students.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final records = snapshot.data!.docs;

                if (records.isEmpty) {
                  return const Center(child: Text('No student records found'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final doc = records[index];

                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.person),
                        ),

                        title: Text(
                          data['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Text(
                          'Register No: ${data['registerNumber'] ?? ''}\n'
                          'Department: ${data['department'] ?? ''}\n'
                          'Email: ${data['email'] ?? ''}',
                        ),

                        isThreeLine: true,

                        // Edit and Delete Menu
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              editStudent(doc.id, data);
                            } else if (value == 'delete') {
                              deleteStudent(doc.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
