import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFirestoreHelper {
  CloudFirestoreHelper._();

  static final CloudFirestoreHelper cloudFirestoreHelper =
      CloudFirestoreHelper._();

  //static final
  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  late CollectionReference studentsRef;
  late CollectionReference countersRef;

  //todo: connectWithStudentsCollection

  void connectWithStudentsCollection() {
    studentsRef = firebaseFirestore.collection("Students");
  }

  void connectWithCountersCollection() {
    countersRef = firebaseFirestore.collection("counters");
  }

//todo:insertRecord
  Future<void> insertRecord({required Map<String, dynamic> data}) async {
    //Future<void> insertRecord(data) async {
    connectWithStudentsCollection();
    connectWithCountersCollection();
    // Map<String, dynamic> data = {
    //   'name': 'kishan',
    //   'age': 18,
    //   'city': 'surat',
    // };
    //--------------------------------------------------------
    //todo: feach counter value from student counter collection
    DocumentSnapshot documentSnapshot =
        await countersRef.doc('Students-counter').get();
    Map<String, dynamic> counterData =
        documentSnapshot.data() as Map<String, dynamic>;

    int counter = counterData['counter']; //0
    //todo: insert a new document with that fetched counter value
    await studentsRef.doc('${++counter}').set(data);

    //todo: update counter value in db
    await countersRef.doc('Students-counter').update({'counter': counter});
    //------------------------------------------------------------------
    //await studentsRef.doc('${++counter}').set(data);
    // DocumentReference res = await studentsRef.add(data);
    // print("-------------------------------");
    // print(res.id);
    // print(res.path);
    // print("-------------------------------");
    // return res;
    //await studentsRef.add(data);
  }

// todo:selectRecord
//   Future<void> insertRecord() async {
//     connectWithStudentsCollection();
//     Map<String, dynamic> data = {
//       'name': 'd',
//       "age": 12,
//       "city": "mumbai",
//     };
//     await studentsRef.doc('3').set(data);
//   }

  Stream<QuerySnapshot> selectRecord() {
    connectWithStudentsCollection();

    return studentsRef.snapshots();
  }
//todo: updateRecord

  Future<void> updateRecord(
      {required String id, required Map<String, dynamic> updateData}) async {
    connectWithStudentsCollection();
    // Map<String, dynamic> updateData = {'name': 'Sagar'};

    await studentsRef.doc(id).update(updateData);
  }

//todo: deleteRecord
  Future<void> deleteRecord({required String id}) async {
    connectWithStudentsCollection();

    await studentsRef.doc(id).delete();
    DocumentSnapshot documentSnapshot =
        await countersRef.doc('Students-counter').get();

    Map<String, dynamic> counterData =
        documentSnapshot.data() as Map<String, dynamic>;

    int counter = counterData['counter'];

    await countersRef.doc('Students-counter').set({'counter': --counter});
  }
}
