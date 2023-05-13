import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/helper/cloud_firestore_helper.dart';
import 'package:firebase_app/helper/firebase_auth_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../global.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> insertFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    User? data = ModalRoute.of(context)!.settings.arguments as User?;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Home Page"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuthHelper.firebaseAuthHelper.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/", (route) => false);
            },
            icon: const Icon(Icons.power_settings_new),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: CloudFirestoreHelper.cloudFirestoreHelper.selectRecord(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("ERROR : ${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            QuerySnapshot? data = snapshot.data;
            List<QueryDocumentSnapshot> documents = data!.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  child: ListTile(
                    //leading : Text("${documents[index].id}"),
                    leading: Text("${index + 1}"),
                    title: Text("${documents[index]['name']}"),
                    trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () async {
                              /*await CloudFirestoreHelper.cloudFirestoreHelper
                                  .updateRecord(id: "${documents[index]}");*/
                              validateAndEditData(id: "${documents[index].id}");
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                              onPressed: () async {
                                await CloudFirestoreHelper.cloudFirestoreHelper
                                    .deleteRecord(id: "${documents[index].id}");
                              },
                              icon: const Icon(Icons.delete))
                        ]),
                    subtitle: Text(
                        "${documents[index]['city']}\n${documents[index]['age']}"),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage("${data!.photoURL}"),
            ),
            const Divider(
              indent: 20,
              endIndent: 20,
              color: Colors.black87,
            ),
            (data!.displayName != null)
                ? Text("Name = ${data!.displayName}")
                : const Text("Name = ---"),
            (data!.email != null)
                ? Text("Name = ${data!.email}")
                : const Text("Name = ---"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          setState(() async {
            await validateAndInsertData();
          });
        },
      ),
    );
  }

  validateAndInsertData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Insert Record"),
        actions: [
          ElevatedButton(
              onPressed: () async {
                if (insertFormKey.currentState!.validate()) {
                  insertFormKey.currentState!.save();
                  Map<String, dynamic> data = {
                    'name': Global.name,
                    'age': Global.age,
                    'city': Global.city,
                  };
                  /*CloudFirestoreHelper.cloudFirestoreHelper
                      .insertRecord(data: data);*/
                  CloudFirestoreHelper.cloudFirestoreHelper
                      .insertRecord(data: data);
                  nameController.clear();
                  ageController.clear();
                  cityController.clear();
                  setState(() {
                    Global.name = "";
                    Global.age = 0;
                    Global.city = "";
                  });
                  Navigator.of(context).pop();

                  // await CloudFirestoreHelper.cloudFirestoreHelper
                  //     .insertRecord();
                }
              },
              child: const Text("Insert")),
          ElevatedButton(
              onPressed: () async {
                nameController.clear();
                ageController.clear();
                cityController.clear();
                setState(() {
                  Global.name = "";
                  Global.age = 0;
                  Global.city = "";
                });
                Navigator.of(context).pop();
              },
              child: const Text("Cancel")),
        ],
        content: Form(
          key: insertFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "name",
                    hintText: "Enter name here..."),
                controller: nameController,
                validator: (val) => (val!.isEmpty) ? "Enter name first" : null,
                onSaved: (val) {
                  Global.name = val;
                },
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "age",
                    hintText: "Enter age here..."),
                controller: ageController,
                validator: (val) => (val!.isEmpty) ? "Enter age first" : null,
                onSaved: (val) {
                  Global.age = int.parse(val!);
                },
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "city",
                    hintText: "Enter city here..."),
                controller: cityController,
                validator: (val) => (val!.isEmpty) ? "Enter city first" : null,
                onSaved: (val) {
                  Global.city = val;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  validateAndEditData({required String id}) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Records"),
        content: Form(
          key: updateFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                validator: (val) {
                  (val!.isEmpty) ? "Enter Name First..." : null;
                },
                onSaved: (val) {
                  Global.name = val;
                },
                controller: nameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Name Here....",
                    labelText: "Name"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                validator: (val) {
                  (val!.isEmpty) ? "Enter Age First..." : null;
                },
                onSaved: (val) {
                  Global.age = int.parse(val!);
                },
                controller: ageController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Age Here....",
                    labelText: "Age"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                validator: (val) {
                  (val!.isEmpty) ? "Enter City First..." : null;
                },
                onSaved: (val) {
                  Global.city = val;
                },
                controller: cityController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter City Here....",
                    labelText: "City"),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text("Update"),
            onPressed: () {
              if (updateFormKey.currentState!.validate()) {
                updateFormKey.currentState!.save();

                Map<String, dynamic> data = {
                  'name': Global.name,
                  'age': Global.age,
                  'city': Global.city,
                };
                CloudFirestoreHelper.cloudFirestoreHelper
                    .updateRecord(id: id, updateData: data);
              }
              nameController.clear();
              ageController.clear();
              cityController.clear();

              Global.name = "";
              Global.age = 0;
              Global.city = "";
              Navigator.of(context).pop();
            },
          ),
          OutlinedButton(
            child: const Text("Cancel"),
            onPressed: () {
              nameController.clear();
              ageController.clear();
              cityController.clear();

              Global.name = null;
              Global.age = null;
              Global.city = null;

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
