import 'package:flutter/material.dart';
import 'package:flutter_sqflite_tutorial/data/local/db_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  List<Map<String, dynamic>> allNotes = [];

  DBHeler? dbRef;

  @override
  initState() {
    super.initState();
    dbRef = DBHeler.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(allNotes[index][DBHeler.COLUMN_NOTE_TITLE]),
                  subtitle: Text(allNotes[index][DBHeler.COLUMN_NOTE_DESC]),
                  trailing: SizedBox(
                    width: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return NoteBottomSheetView(
                                    onNoteRefetched: getNotes,
                                    isUpdate: true,
                                    sno: allNotes[index][DBHeler.COLUMN_NOTE_SNO],
                                    title: allNotes[index][DBHeler.COLUMN_NOTE_TITLE],
                                    desc: allNotes[index][DBHeler.COLUMN_NOTE_DESC],
                                  );
                                });
                          },
                          child: const Icon(Icons.edit_outlined),
                        ),
                        InkWell(
                          onTap: () async{
                            final isSuccess = await dbRef!.deleteNote(sno: allNotes[index][DBHeler.COLUMN_NOTE_SNO]);
                            if(isSuccess){
                              getNotes();
                            }
                          },
                          child: const Icon(
                            Icons.delete_outlined,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text('No notes yet'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return NoteBottomSheetView(
                  onNoteRefetched: () => getNotes(),
                );
              });
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}

class NoteBottomSheetView extends StatefulWidget {
  const NoteBottomSheetView({
    required this.onNoteRefetched,
    this.isUpdate = false,
    this.sno = 0,
    this.title = '',
    this.desc = '',
    super.key,
  });

  final VoidCallback? onNoteRefetched;
  final bool isUpdate;
  final int sno;
  final String title;
  final String desc;

  @override
  State<NoteBottomSheetView> createState() => _NoteBottomSheetViewState();
}

class _NoteBottomSheetViewState extends State<NoteBottomSheetView> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DBHeler? dbRef;




  @override
  void initState() {
    super.initState();
    dbRef = DBHeler.getInstance;
    _titleController.text = widget.title;
    _descController.text = widget.desc;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.isUpdate ? 'Edit' : 'Add'} Note',
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 24,
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter title here',
                  labelText: 'Title',
                  focusedBorder:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  hintText: 'Enter description here',
                  labelText: 'Description',
                  focusedBorder:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(width: 1),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Center(
                        child: Text('Cancel'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(width: 1),
                        ),
                      ),
                      onPressed: () async {
                        bool hasTitle = _titleController.text.trim().isNotEmpty;
                        bool hasDesc = _descController.text.trim().isNotEmpty;
          
            
          
                        if (hasTitle && hasDesc) {
                          final isSuccess = widget.isUpdate ? await dbRef!.updateNote(
                          title: _titleController.text,
                          desc: _descController.text,
                          sno: widget.sno,
                        )
                        : await dbRef!.addNote(
                          title: _titleController.text,
                          desc: _descController.text,
                        );
          
                          if (isSuccess) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            widget.onNoteRefetched?.call();
                          }
                        } else {
                          Fluttertoast.showToast(msg: 'All fields are required');
                        }
                      },
                      child:  Center(
                        child: Text('${widget.isUpdate ? 'Edit': 'Add'} Note'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
