// import 'package:british_body_admin/material/materials.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';

// class UsersStatus extends StatefulWidget {
//   final String email;
//   final Map<String, bool> haslogeding;
//   const UsersStatus(
//       {super.key, required this.email, required this.haslogeding});

//   @override
//   State<UsersStatus> createState() => _UsersStatusState();
// }

// class _UsersStatusState extends State<UsersStatus> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('کارمەندەکان'),
//         foregroundColor: Colors.white,
//         backgroundColor: Material1.primaryColor,
//         centerTitle: true,
//       ),
//       body: SizedBox(
//         height: 80.h,
//         child: StreamBuilder(
//           stream: FirebaseFirestore.instance.collection('user').snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             return ListView.builder(
//                 itemCount: snapshot.data?.docs.length ?? 0,
//                 itemBuilder: (BuildContext context, int index) {
//                   return GestureDetector(
//                     child: SizedBox(
//                         height: 15.h,
//                         width: 90.w,
//                         child: Container(
//                           margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
//                           padding: EdgeInsets.all(1.h),
//                           decoration: BoxDecoration(
//                             color: snapshot.data!.docs[index]['checkin']
//                                 ? Colors.green
//                                 : (widget.haslogeding[
//                                             "${snapshot.data!.docs[index]['email']}"] ??
//                                         false)
//                                     ? Colors.amber
//                                     : Colors.red,
//                             borderRadius: BorderRadius.circular(5),
//                             boxShadow: const [
//                               BoxShadow(
//                                 color: Colors.grey,
//                                 blurRadius: 5,
//                               )
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 "${snapshot.data!.docs[index]['name']} : ناو",
//                                 style: const TextStyle(
//                                   fontSize: 20,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 "${snapshot.data!.docs[index]['phonenumber']} : ژمارەی مۆبایل",
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 15,
//                                 ),
//                               ),
//                               Text(
//                                 "${snapshot.data!.docs[index]['email']} : ئیمەیل",
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 15,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )),
//                   );
//                 });
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class UsersStatus extends StatefulWidget {
  final String email;
  final Map<String, bool> haslogeding;
  const UsersStatus({
    super.key,
    required this.email,
    required this.haslogeding,
  });

  @override
  State<UsersStatus> createState() => _UsersStatusState();
}

class _UsersStatusState extends State<UsersStatus> {
  List<DocumentSnapshot> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('user').get();
      setState(() {
        _users = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Optionally handle error (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('کارمەندەکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: SizedBox(
        height: 80.h,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _users.isEmpty
                ? const Center(child: Text('No users found'))
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: SizedBox(
                          height: 15.h,
                          width: 90.w,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                            padding: EdgeInsets.all(1.h),
                            decoration: BoxDecoration(
                              color: _users[index]['checkin']
                                  ? Colors.green
                                  : (widget.haslogeding[
                                          "${_users[index]['email']}"] ??
                                      false)
                                      ? Colors.amber
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${_users[index]['name']} : ناو",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${_users[index]['phonenumber']} : ژمارەی مۆبایل",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "${_users[index]['email']} : ئیمەیل",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
} 