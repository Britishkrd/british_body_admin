import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Admindeletetarget extends StatefulWidget {
  final String email;
  const Admindeletetarget({super.key, required this.email});

  @override
  State<Admindeletetarget> createState() => _AdmindeletetargetState();
}

class _AdmindeletetargetState extends State<Admindeletetarget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سڕینەوەی تارگێت'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('target')
              .where('email', isEqualTo: widget.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return SizedBox(
              height: 80.h,
              child: ListView.builder(
                itemCount: snapshot.data?.docs.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
                    child: Card(
                      child: ListTile(
                        title: Text(snapshot.data!.docs[index]['title']),
                        subtitle: Text(snapshot.data!.docs[index]['target']),
                        trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                          'دڵنیایت لە سڕینەوەی ئەم تارگێت'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('target')
                                                  .doc(snapshot
                                                      .data!.docs[index].id)
                                                  .delete()
                                                  .then((value) {
                                                Navigator.pop(context);
                                              });
                                            },
                                            child: Text('بەڵێ',
                                                style: TextStyle(
                                                    color: Colors.red))),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('نەخێر'))
                                      ],
                                    );
                                  });
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            )),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
