import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/ehsan_task/admin/employee_tasks_view.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/ehsan_task/employee/task_view_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ChooseUserForTasks extends StatefulWidget {
  final String adminEmail;

  const ChooseUserForTasks({super.key, required this.adminEmail});

  @override
  State<ChooseUserForTasks> createState() => _ChooseUserForTasksState();
}

class _ChooseUserForTasksState extends State<ChooseUserForTasks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بینینی ئەرکی کارمەندەکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No employees found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] as String? ?? 'No Name';
              final phone = data['phonenumber'] as String? ?? 'No Phone';
              final email = data['email'] as String? ?? 'No Email';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmployeeTasksView(
                        email: email,
                        name: name,
                      )
                    ),
                  );
                },
                child: _buildEmployeeCard(name, phone, email),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmployeeCard(String name, String phone, String email) {
    return SizedBox(
      height: 15.h,
      width: 90.w,
      child: Container(
        margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
        padding: EdgeInsets.all(1.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "$name : ناو",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("$phone : ژمارەی مۆبایل",
                style: const TextStyle(fontSize: 15)),
            Text("$email : ئیمەیل", style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
