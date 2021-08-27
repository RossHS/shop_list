import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  const TestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FireBase Testing'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _add,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green)),
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
              TextButton(
                onPressed: _remove,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
          const Expanded(child: _Body()),
        ],
      ),
    );
  }

  static void _add() {
    var rnd = Random();
    FirebaseFirestore.instance.collection('test').add({
      'random_num': rnd.nextInt(100),
    });
  }

  static Future<void> _remove() async {
    final batch = FirebaseFirestore.instance.batch();
    var list = await FirebaseFirestore.instance.collection('test').get();
    if (list.docs.isNotEmpty) {
      batch.delete(list.docs[Random().nextInt(list.docs.length)].reference);
      batch.commit();
    }
  }
}

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  static Stream<QuerySnapshot> getStream() => FirebaseFirestore.instance
      .collection('test')
      .orderBy('random_num')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data;
          if (data != null) {
            return ListView.builder(
                itemCount: data.docs.length,
                itemBuilder: (context, index) =>
                    Text('${data.docs[index].get('random_num')}'));
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
