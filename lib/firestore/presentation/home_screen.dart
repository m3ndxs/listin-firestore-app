import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:listin/firestore/helpers/firestore_analytics.dart';
import 'package:listin/firestore/models/listin.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listin> listListins = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirestoreAnalytics analytics = FirestoreAnalytics();

  @override
  void initState() {
    refresh();
    analytics.incrementarAcessosTotais();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Listin - Feira Colaborativa",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: Icon(Icons.add),
      ),
      body: (listListins.isEmpty)
          ? const Center(
              child: Text(
                "Nenhuma lista ainda.\nVamos criar a primeira?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                analytics.incrementarAtualizacoesManuais();
                return refresh();
              },
              child: ListView(
                children: List.generate(listListins.length, (index) {
                  Listin model = listListins[index];
                  return Dismissible(
                    key: ValueKey<Listin>(model),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white,),
                    ),
                    onDismissed: (direction) {
                      remove(model);
                    },
                    child: ListTile(
                      onTap: () {
                        print("Clicou Aqui");
                      },
                      onLongPress: () {
                        showFormModal(model: model);
                      },
                      leading: const Icon(Icons.list_alt_rounded),
                      title: Text(model.name),
                      subtitle: Text(model.id),
                    ),
                  );
                }),
              ),
            ),
    );
  }

  dynamic showFormModal({Listin? model}) {
    String labelTitle = "Adicionar Lista";
    String confirmationButton = "Salvar";
    String skipButton = "Cancelar";

    TextEditingController nameController = TextEditingController();

    if (model != null) {
      labelTitle = "Editando ${model.name}";
      nameController.text = model.name;
    }

    showModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32),
          child: ListView(
            children: [
              Text(
                labelTitle,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  label: Text("Nome do Listin"),
                ),
              ),
              Padding(padding: EdgeInsetsGeometry.only(bottom: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(skipButton),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Listin listin = Listin(
                        id: const Uuid().v1(),
                        name: nameController.text,
                      );

                      if (model != null) {
                        listin.id = model.id;
                      }

                      firestore
                          .collection("listins")
                          .doc(listin.id)
                          .set(listin.toMap());

                      refresh();
                      analytics.incrementarListasAdicionadas();

                      Navigator.pop(context);
                    },
                    child: Text(confirmationButton),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  dynamic refresh() async {
    List<Listin> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection("listins")
        .get();

    for (var doc in snapshot.docs) {
      temp.add(Listin.fromMap(doc.data()));
    }

    setState(() {
      listListins = temp;
    });
  }

  void remove(Listin model) {
    firestore.collection('listins').doc(model.id).delete();
    refresh();
  }
}
