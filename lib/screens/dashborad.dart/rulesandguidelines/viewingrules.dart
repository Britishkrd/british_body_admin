import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Viewingrules extends StatefulWidget {
  final bool issubdept;
  final DocumentReference<Map<String, dynamic>> department;
  final bool isdelete;
  final bool issubdeptdelte;
  final String subdept;
  const Viewingrules(
      {super.key,
      required this.department,
      required this.isdelete,
      required this.issubdept,
      required this.subdept,
      required this.issubdeptdelte});

  @override
  State<Viewingrules> createState() => _ViewingrulesState();
}

class _ViewingrulesState extends State<Viewingrules> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بینینی یاساکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: widget.issubdept
              ? widget.department
                  .collection('rules')
                  .doc(widget.subdept)
                  .collection(widget.subdept)
                  .snapshots()
              : widget.department.collection('rules').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('هیچ یاسەکی نییە'));
            }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(127),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          title:
                              Text(snapshot.data!.docs[index].data()['title']),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  snapshot.data!.docs[index].data()['content']),
                            ),
                          ],
                        ),
                      ),
                      if (widget.issubdeptdelte)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text(
                                            'دڵنیایت لە سڕینەوەی ئەم یاسایە؟'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('نەخێر')),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                widget.department
                                                    .collection('rules')
                                                    .doc(widget.subdept)
                                                    .collection(widget.subdept)
                                                    .doc(snapshot
                                                        .data!.docs[index].id)
                                                    .delete();
                                              },
                                              child: const Text('بەڵێ')),
                                        ],
                                      ));
                            },
                          ),
                        ),
                      if (widget.isdelete)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text(
                                            'دڵنیایت لە سڕینەوەی ئەم یاسایە؟'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('نەخێر')),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                widget.department
                                                    .collection('rules')
                                                    .doc(snapshot
                                                        .data!.docs[index].id)
                                                    .delete();
                                              },
                                              child: const Text('بەڵێ')),
                                        ],
                                      ));
                            },
                          ),
                        )
                    ],
                  );
                });
          }),
    );
  }
}
