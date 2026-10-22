import 'package:apk_notas_firebase/service/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService notesService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notas")),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(stream: notesService.read(), builder: (context, snapshot){
        if(snapshot.hasData){
          List noteList = snapshot.data!.docs;
          return ListView.builder(itemCount: noteList.length,
          itemBuilder: (context, index){
            DocumentSnapshot document = noteList[index];
            String docID = document.id;
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String noteText = data['note'] ?? '';

            return ListTile(
              title: Text(noteText),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () => openNoteBox(docID: docID, note: noteText), icon: Icon(Icons.edit)),
                  IconButton(onPressed: () => notesService.delete(docID), icon: Icon(Icons.delete)),
                ],
              ),
            );
          }
          );
        }
        else{
          return Text("Sem notas...");
        }
      }),
    );
  }

  void openNoteBox({String? docID, String? note}) {
    textController.text = note ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(controller: textController),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                notesService.create(textController.text);
              } else {
                notesService.update(docID, textController.text);
              }
            },
            child: Text(docID == null ? "Adicionar" : "Salvar"),
          ),
        ],
      ),
    );
  }
}
