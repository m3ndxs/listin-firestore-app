import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listin/firestore_produtos/helpers/enum_order.dart';
import 'package:listin/firestore_produtos/model/produto.dart';

class ProdutoService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void adicionarProduto({required String listinId, required Produto produto}) {
    firestore
        .collection("listins")
        .doc(listinId)
        .collection("produtos")
        .doc(produto.id)
        .set(produto.toMap());
  }

  Future<List<Produto>> lerProdutos({
    required String listinId,
    required OrderProduct order,
    required bool isDescending,
    QuerySnapshot<Map<String, dynamic>>? snapshot,
  }) async {
    List<Produto> temp = [];

    snapshot ??= await firestore
        .collection("listins")
        .doc(listinId)
        .collection("produtos")
        // .where("isComprado", isEqualTo: isComprado)
        .orderBy(order.name, descending: isDescending)
        .get();

    for (var doc in snapshot.docs) {
      Produto produto = Produto.fromMap(doc.data());

      temp.add(produto);
    }

    return temp;
  }

  void alternarComprado({
    required Produto produto,
    required String listinId,
  }) async {
    produto.isComprado = !produto.isComprado;

    await firestore
        .collection("listins")
        .doc(listinId)
        .collection("produtos")
        .doc(produto.id)
        .update({"isComprado": produto.isComprado});
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> conectarStream({
    required Function onChange,
    required String listinId,
    required OrderProduct order,
    required bool isDescending,
  }) {
    return firestore
        .collection("listins")
        .doc(listinId)
        .collection("produtos")
        .orderBy(order.name, descending: isDescending)
        .snapshots()
        .listen((snapshot) {
          onChange(snapshot: snapshot);
        });
  }

  Future<void> removerProduto({
    required Produto produto,
    required String listinId,
  }) async {
    return await firestore
        .collection("listins")
        .doc(listinId)
        .collection("produtos")
        .doc(produto.id)
        .delete();
  }
}
