import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreAnalytics {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void incrementarAcessosTotais() {
    _incrementar("acessos_totais");
  }

  void incrementarListasAdicionadas() {
    _incrementar("listas_adicionadas");
  }

  void incrementarAtualizacoesManuais() {
    _incrementar("atualizacoes_manuais");
  }

  dynamic _incrementar(String field) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await firestore.collection("analytics").doc("geral").get();

    Map<String, dynamic> document = {};

    if(snapshot.data() != null) {
      document = snapshot.data()!;
    }
    if(document[field] != null ) {
      document[field] += 1; 
    } else {
      document[field] = 1;
    }

    firestore.collection("analytics").doc("geral").set(document);
  }
}